class profiles::backup::rds (
  String $backupdir                   = '/data/rdsbackups',
) inherits profiles {
  file { $backupdir:
    ensure => 'directory',
    owner  => 'ubuntu',
    group  => 'ubuntu',
  }

  $config = lookup('rds_hiera_configs', { merge => 'hash' })

  file { '/usr/local/bin/dump_rds.sh':
    ensure  => file,
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0750',
    content => template('profiles/backupserver/dump_rds.sh.erb'),
  }

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
