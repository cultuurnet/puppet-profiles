class profiles::backup::rds (
  String            $backupdir         = '/data/rdsbackups',
  Boolean           $lvm               = false,
  Optional[String]  $volume_group      = undef,
  Optional[String]  $volume_size       = undef,
  Hash              $extra_rds_configs = lookup(
    'profiles::backup::rds::extra_rds_configs',
    { default_value => {} }
  ),
) inherits profiles {

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'mysql_rds_backups':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => $backupdir,
      fs_type      => 'ext4',
      owner        => 'ubuntu',
      group        => 'ubuntu',
    }
  } else {
    file { $backupdir:
      ensure => 'directory',
      owner  => 'ubuntu',
      group  => 'ubuntu',
    }
  }

  # Terraform-provided RDS configs
  $terraform_rds_configs = lookup('rds_hiera_configs', { merge => 'hash' })

  # Normalize Terraform configs
  $normalized_terraform = $terraform_rds_configs.map |$k, $v| {
    [$k, {
      'host'     => $v['terraform::rds::host'],
      'user'     => $v['terraform::rds::user'],
      'password' => $v['terraform::rds::password'],
      'database' => $v['terraform::rds::database'],
    }]
  }.to_h

  # Normalize extra (non-Terraform) configs
  $normalized_extra = $extra_rds_configs.map |$k, $v| {
    [$k, {
      'host'     => $v['rds::host'],
      'user'     => $v['rds::user'],
      'password' => $v['rds::password'],
      'database' => $v['rds::database'],
    }]
  }.to_h

  # Merge both sources
  $all_rds_configs = deep_merge($normalized_terraform, $normalized_extra)

  # Write runtime YAML config
  file { "${backupdir}/rds_servers.yml":
    ensure  => file,
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0600',
    content => inline_epp(@("EPP"), { 'servers' => $all_rds_configs })
<% @servers.each do |name, cfg| -%>
<%= name %>:
  host: <%= cfg['host'] %>
  user: <%= cfg['user'] %>
  password: <%= cfg['password'] %>
  database: <%= cfg['database'] %>
<% end -%>
| EPP
  }

  # Dump script
  file { '/usr/local/bin/dump_rds.sh':
    ensure  => file,
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0750',
    content => template('profiles/backupserver/dump_rds.sh.erb'),
  }

  # Backup cron
  cron { 'rds-backup-all':
    ensure      => present,
    environment => ['TZ=Europe/Brussels', 'MAILTO=infra+cron@publiq.be'],
    user        => 'ubuntu',
    minute      => '0',
    hour        => '2',
    weekday     => '0',
    command     => '/usr/local/bin/dump_rds.sh',
  }

  cron { 'rds-backup-cleanup':
    ensure      => present,
    environment => ['TZ=Europe/Brussels', 'MAILTO=infra+cron@publiq.be'],
    user        => 'ubuntu',
    minute      => '0',
    hour        => '1',
    weekday     => '0',
    command     => "/bin/rm -f ${backupdir}/*.sql.gz",
  }
}
