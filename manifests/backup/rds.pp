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
    $normalized_terraform = $terraform_rds_configs.reduce({}) |$acc, $kv| {
      $acc + {
        $kv[0] => {
          'host'     => $kv[1]['terraform::rds::host'],
          'user'     => $kv[1]['terraform::rds::user'],
          'password' => $kv[1]['terraform::rds::password'],
          'database' => $kv[1]['terraform::rds::database'],
        }
      }
    }

    

    # Normalize extra (non-Terraform) configs
    $normalized_extra = $extra_rds_configs.reduce({}) |$acc, $kv| {
      $acc + {
        $kv[0] => {
          'host'     => $kv[1]['rds::host'],
          'user'     => $kv[1]['rds::user'],
          'password' => $kv[1]['rds::password'],
          'database' => $kv[1]['rds::database'],
      }
      }
    }

  # Merge both sources
  $all_rds_configs = deep_merge($normalized_terraform, $normalized_extra)

  # Write runtime YAML config
  $rds_file_content = $all_rds_configs.reduce('') |$acc, $pair| {
    $name = $pair[0]
    $cfg  = $pair[1]
    "${acc}${name}:\n  host: ${cfg['host']}\n  user: ${cfg['user']}\n  password: ${cfg['password']}\n  database: ${cfg['database']}\n"
  }

  file { "${backupdir}/rds_servers.yml":
    ensure  => file,
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0600',
    content => $rds_file_content,
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
