class profiles::redis::backup (
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

    profiles::lvm::mount { 'redisbackup':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/backup/redis',
      fs_type      => 'ext4'
    }
  } else {

    realize File['/data']
    realize File['/data/backup']

    file { '/data/backup/redis':
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File['/data/backup']
    }
  }

  file { '/data/backup/redis/archive':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/data/backup/redis']
  }

  cron { "Cleanup old redis backups":
    command  => "/usr/bin/find /data/backup/redis/archive -type f -mtime +${mtime} -delete",
    user     => 'root',
    hour     => '5',
    minute   => '30',
    weekday  => '*',
    monthday => '*',
    month    => '*',
    require  => File['/data/backup/redis/archive']
  }
}
