class profiles::elasticsearch (
  Optional[String] $version       = undef,
  Integer          $major_version = if $version { Integer(split($version, /\./)[0]) } else { 5 },
  Boolean          $lvm           = false,
  Optional[String] $volume_group  = undef,
  Optional[String] $volume_size   = undef
) inherits ::profiles {

  if ($version and $major_version) {
    if Integer(split($version, /\./)[0]) != $major_version {
      fail("Profiles::Elasticsearch: incompatible combination of 'version' and 'major_version' parameters")
    }
  }

  $data_dir = '/var/lib/elasticsearch'

  contain ::profiles::java

  realize Apt::Source["elastic-${major_version}.x"]
  realize Group['elasticsearch']
  realize User['elasticsearch']

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'elasticsearchdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/elasticsearch',
      fs_type      => 'ext4',
      owner        => 'elasticsearch',
      group        => 'elasticsearch',
      require      => [Group['elasticsearch'], User['elasticsearch']],
      before       => Class['::elasticsearch']
    }

    mount { $data_dir:
      ensure  => 'mounted',
      device  => '/data/elasticsearch',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['elasticsearchdata'], Class['::elasticsearch']]
    }
  }

  sysctl { 'vm.max_map_count':
    value  => '262144',
    before => Class['elasticsearch']
  }

  class { '::elasticsearch':
    version           => $version ? {
                           undef   => false,
                           default => $version
                         },
    manage_repo       => false,
    api_timeout       => 30,
    restart_on_change => true,
    instances         => {},
    require           => [Apt::Source["elastic-${major_version}.x"], Class['::profiles::java']]
  }

  class { 'profiles::elasticsearch::backup':
    require => Class['::elasticsearch']
  }
}
