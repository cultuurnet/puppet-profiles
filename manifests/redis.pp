class profiles::redis (
  String           $version          = 'installed',
  Boolean          $lvm              = false,
  Optional[String] $volume_group     = undef,
  Optional[String] $volume_size      = undef
) inherits ::profiles {

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

    file { '/var/lib/redis':
      ensure  => 'link',
      target  => '/data/redis',
      force   => true,
      owner   => 'redis',
      group   => 'redis',
      require => [File['/var/lib/redis'], Profiles::Lvm::Mount['redisdata']],
      before  => Class['redis']
    }
  }

  class { '::redis':
    workdir      => '/var/lib/redis',
    workdir_mode => '0755',
    require      => [Group['redis'], User['redis']]
  }
}
