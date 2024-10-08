class profiles::backup::server::mysql_legacy (
  Array                          $servers               = [],
  String                         $backup_user           = 'backup',
  String                         $backup_password,
  String                         $backupdir             = '/data/mysql_legacy_backups',
  Boolean                        $lvm                   = false,
  Optional[String]               $volume_group          = undef,
  Optional[String]               $volume_size           = undef
) inherits ::profiles {

  realize Package['mysql-client']

  $serverlist = join($servers, ' ')

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'mysql_legacy_backups':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => $backupdir,
      fs_type      => 'ext4',
      owner        => 'ubuntu',
      group        => 'ubuntu'
    }
  } else {
    file { $backupdir:
      ensure  => 'directory',
      owner   => 'ubuntu',
      group   => 'ubuntu'
    }
  }

  # script
  file { '/usr/local/bin/mysql_legacy_backup.sh':
    source  => 'puppet:///modules/profiles/backup/server/mysql_legacy_backup.sh',
    ensure  => 'file',
    mode    => '0755',
  }

  # cron
  cron { 'mysql-legacy-backup':
    command     => "/usr/local/bin/mysql_legacy_backup.sh",
    environment => ["MYSQL_SERVERS=\'${serverlist}\'", "BACKUP_USER=${backup_user}", "BACKUP_PASSWORD=${backup_password}", "BACKUPDIR=${backupdir}"],
    user        => 'root',
    hour        => '4',
    minute      => '0',
    weekday     => '*',
    monthday    => '*',
    month       => '*',
    require     => File['/usr/local/bin/mysql_legacy_backup.sh']
  }

 
  # cleanup cron
  cron { "Cleanup old MySQL backups":
    command  => "/usr/bin/find ${backupdir} -type f -name '*.sql.gz' -mtime +7 -delete",
    user     => 'root',
    hour     => '4',
    minute   => '45',
    weekday  => '*',
    monthday => '*',
    month    => '*',
    require  => Cron['mysql-legacy-backup']
  }

}
