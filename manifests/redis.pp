class profiles::redis (
  String           $version          = 'installed',
  Boolean          $persist_data     = true,
  Boolean          $lvm              = false,
  Optional[String] $volume_group     = undef,
  Optional[String] $volume_size      = undef,
  Optional[String] $maxmemory        = undef,
  Optional[String] $maxmemory_policy = undef
) inherits ::profiles {

  $workdir = '/var/lib/redis'

  include profiles::firewall::rules

  realize Group['redis']
  realize User['redis']
  realize Firewall['400 accept redis traffic']

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
    package_ensure   => $version,
    workdir          => $workdir,
    workdir_mode     => '0755',
    save_db_to_disk  => $persist_data,
    service_manage   => false,
    maxmemory        => $maxmemory,
    maxmemory_policy => $maxmemory_policy,
    require          => [Group['redis'], User['redis']],
    notify           => Service['redis-server']
  }

  service { 'redis-server':
    enable    => true,
    ensure    => 'running',
    hasstatus => true
  }
}
