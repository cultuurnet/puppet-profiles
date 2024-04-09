class profiles::mysql::server::backup (
  Optional[String] $password       = undef,
  Boolean          $lvm            = false,
  Optional[String] $volume_group   = undef,
  Optional[String] $volume_size    = undef,
  Integer          $retention_days = 7
) inherits ::profiles {

  $mtime = $retention_days - 1

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'mysqlbackup':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/backup/mysql',
      fs_type      => 'ext4',
      before       => Class['mysql::server::backup']
    }
  } else {

    realize File['/data']
    realize File['/data/backup']

    file { '/data/backup/mysql':
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File['/data/backup'],
      before  => Class['mysql::server::backup']
    }
  }

  file { '/data/backup/mysql/archive':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/data/backup/mysql'],
    before  => Class['mysql::server::backup']
  }

  class { '::mysql::server::backup':
    backupuser         => 'backup',
    backuppassword     => $password,
    backupdir          => '/data/backup/mysql/current',
    backuprotate       => 1,
    file_per_database  => true,
    prescript          => 'rm /data/backup/mysql/current/*',
    postscript         => 'cp /data/backup/mysql/current/* /data/backup/mysql/archive',
    time               => [1, 5],
    excludedatabases   => ['mysql', 'sys', 'information_schema', 'performance_schema']
  }

  cron { "Cleanup old MySQL backups":
    command  => "/usr/bin/find /data/backup/mysql/archive -type f -mtime +${mtime} -delete",
    user     => 'root',
    hour     => '4',
    minute   => '15',
    weekday  => '*',
    monthday => '*',
    month    => '*',
    require  => File['/data/backup/mysql/archive']
  }
}
