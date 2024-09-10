class profiles::redis::backup (
  Boolean                           $lvm            = false,
  Optional[String]                  $volume_group   = undef,
  Optional[String]                  $volume_size    = undef,
  Optional[Enum['hourly', 'daily']] $schedule       = undef,
  Integer                           $retention_days = 7
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

  file { '/data/backup/redis/current':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/data/backup/redis']
  }

  file { '/data/backup/redis/archive':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/data/backup/redis']
  }

  file { '/usr/local/sbin/redisbackup.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('profiles/redis/redisbackup.sh.erb')
  }

  cron { 'redis backup':
    ensure      => $schedule ? {
                     undef   => 'absent',
                     default => 'present'
                   },
    command     => '/usr/local/sbin/redisbackup.sh',
    environment => ['TZ=Europe/Brussels', 'MAILTO=infra+cron@publiq.be'],
    user        => 'root',
    hour        => $schedule ? {
                     'hourly' => '*',
                     default  => '0'
                   },
    minute      => '20',
    weekday     => '*',
    monthday    => '*',
    month       => '*',
    require     => [File['/data/backup/redis/current'], File['/data/backup/redis/archive'], File['/usr/local/sbin/redisbackup.sh']]
  }
}
