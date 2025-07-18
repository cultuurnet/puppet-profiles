class profiles::mongodb (
  String                     $version               = 'installed',
  Stdlib::IP::Address::V4    $listen_address        = '127.0.0.1',
  Enum['running', 'stopped'] $service_status        = 'running',
  Boolean                    $lvm                   = false,
  Optional[String]           $volume_group          = undef,
  Optional[String]           $volume_size           = undef,
  Boolean                    $backup_lvm            = false,
  Optional[String]           $backup_volume_group   = undef,
  Optional[String]           $backup_volume_size    = undef,
  Enum['hourly', 'daily']    $backup_schedule       = 'daily',
  Integer                    $backup_retention_days = 7
) inherits ::profiles {

  $data_dir = '/var/lib/mongodb'

  include profiles::firewall::rules

  realize Group['mongodb']
  realize User['mongodb']

  if !($listen_address == '127.0.0.1') {
    realize Firewall['400 accept mongodb traffic']
  }

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'mongodbdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/mongodb',
      fs_type      => 'ext4',
      owner        => 'mongodb',
      group        => 'mongodb',
      require      => [Group['mongodb'], User['mongodb']],
      before       => Class['mongodb::server']
    }

    exec { 'create_mongodb_dbpath':
      command     => "install -o mongodb -g mongodb -d ${data_dir}",
      path        => ['/usr/sbin', '/usr/bin'],
      logoutput   => 'on_failure',
      creates     => $data_dir,
      require     => [Group['mongodb'], User['mongodb']]
    }

    mount { $data_dir:
      ensure  => mounted,
      device  => '/data/mongodb',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['mongodbdata'], Exec['create_mongodb_dbpath']],
      before  => Class['mongodb::server']
    }
  }

  package { 'mongo-tools':
    ensure => 'installed'
  }

  class { 'mongodb::globals':
    manage_package_repo => false
  }

  class { 'mongodb::server':
    package_name   => 'mongodb-server',
    package_ensure => $version,
    service_manage => true,
    service_ensure => $service_status,
    service_enable => $service_status ? {
                        'running' => true,
                        'stopped' => false
                      },
    user           => 'mongodb',
    group          => 'mongodb',
    bind_ip        => [$listen_address],
    require        => [Group['mongodb'], User['mongodb']]
  }

  class { 'profiles::mongodb::backup':
    lvm             => $backup_lvm,
    volume_group    => $backup_volume_group,
    volume_size     => $backup_volume_size,
    backup_schedule => $backup_schedule,
    retention_days  => $backup_retention_days
  }
}
