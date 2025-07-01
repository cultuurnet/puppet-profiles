class profiles::backup::rds (
  String $backupdir                   = '/data/rdsbackups',
) inherits profiles {
  file { $backupdir:
    ensure => 'directory',
    owner  => 'ubuntu',
    group  => 'ubuntu',
  }

  $config = lookup('rds_hiera_configs', { merge => 'hash' })

  $config.each |$db_key, $db| {
    $user     = $db['terraform::rds::user']
    $password = $db['terraform::rds::password']
    $host     = $db['terraform::rds::host']
    $mysqld_version = $db['terraform::rds::mysqld_version']

    cron { "rds-backup-${db_key}":
      ensure      => present,
      environment => ['TZ=Europe/Brussels', 'MAILTO=infra+cron@publiq.be'],
      user        => 'ubuntu',
      minute      => '0',
      hour        => '2',
      weekday     => '0',
      command     => "/usr/bin/mysqldump --host=${host} --user=${user} --password='${password}' " +
      "--databases $(/usr/bin/mysql --host=${host} --user=${user} --password='${password}' " +
      "-N -e \"SHOW DATABASES;\" | grep -Ev '^(information_schema|performance_schema|mysql|sys)$') " +
      "| gzip > ${backupdir}/${db_key}-$(date +\\%F).sql.gz",
    }
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
