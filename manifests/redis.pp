class profiles::redis (
  String           $version      = 'installed',
  Boolean          $persist_data = true,
  Boolean          $lvm          = false,
  Optional[String] $volume_group = undef,
  Optional[String] $volume_size  = undef
) inherits ::profiles {

  $workdir = '/var/lib/redis'

  realize Group['redis']
  realize User['redis']

  if $lvm {

    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'redisdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/redis',
      fs_type      => 'ext4',
      owner        => 'redis',
      group        => 'redis',
      require      => [Group['redis'], User['redis']],
      before       => Class['redis']
    }

    mount { $workdir:
      ensure  => mounted,
      device  => '/data/redis',
      fstype  => 'none',
      options => 'rw,bind',
      notify  => Service['redis-server'],
      require => [Profiles::Lvm::Mount['redisdata'], Class['redis']]
    }
  }

  class { '::redis':
    package_ensure  => $version,
    workdir         => $workdir,
    workdir_mode    => '0755',
    save_db_to_disk => $persist_data,
    service_manage  => false,
    require         => [Group['redis'], User['redis']],
    notify          => Service['redis-server']
  }

  service { 'redis-server':
    enable    => true,
    ensure    => 'running',
    hasstatus => true
  }
}
