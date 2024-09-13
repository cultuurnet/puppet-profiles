class profiles::redis (
  String                            $version               = 'installed',
  Stdlib::IP::Address::V4           $listen_address        = '127.0.0.1',
  Boolean                           $persist_data          = true,
  Boolean                           $appendonly            = false,
  Optional[String]                  $password              = undef,
  Boolean                           $lvm                   = false,
  Optional[String]                  $volume_group          = undef,
  Optional[String]                  $volume_size           = undef,
  Boolean                           $backup_lvm            = false,
  Optional[String]                  $backup_volume_group   = undef,
  Optional[String]                  $backup_volume_size    = undef,
  Optional[Enum['hourly', 'daily']] $backup_schedule       = undef,
  Integer                           $backup_retention_days = 7,
  Optional[String]                  $maxmemory             = undef,
  Optional[String]                  $maxmemory_policy      = undef
) inherits ::profiles {

  $workdir = '/var/lib/redis'

  include profiles::firewall::rules

  realize Group['redis']
  realize User['redis']

  if !($listen_address == '127.0.0.1') {
    realize Firewall['400 accept redis traffic']
  }

  if $appendonly {
    unless $persist_data {
      fail("with appendonly enabled, 'persist_data' must be set to true")
    }
  }


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
    appendonly       => $appendonly,
    bind             => $listen_address,
    requirepass      => $password,
    service_manage   => false,
    maxmemory        => $maxmemory,
    maxmemory_policy => $maxmemory_policy,
    require          => [Group['redis'], User['redis']],
    notify           => Service['redis-server']
  }

  if $persist_data {
    class { 'profiles::redis::backup':
      lvm             => $backup_lvm,
      volume_group    => $backup_volume_group,
      volume_size     => $backup_volume_size,
      backup_schedule => $backup_schedule,
      retention_days  => $backup_retention_days
    }
  }

  service { 'redis-server':
    enable    => true,
    ensure    => 'running',
    hasstatus => true
  }
}
