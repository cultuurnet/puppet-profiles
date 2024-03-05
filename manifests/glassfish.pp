class profiles::glassfish (
  String           $version         = '4.1.2.181',
  String           $password        = 'adminadmin',
  String           $master_password = 'changeit',
  Boolean          $lvm             = false,
  Optional[String] $volume_group    = undef,
  Optional[String] $volume_size     = undef
) inherits ::profiles {

  contain ::profiles::java

  realize Apt::Source['publiq-tools']
  realize Group['glassfish']
  realize User['glassfish']

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'glassfishdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/glassfish',
      fs_type      => 'ext4',
      owner        => 'glassfish',
      group        => 'glassfish',
      require      => [Group['glassfish'], User['glassfish']]
    }

    file { ['/opt/payara', '/opt/payara/glassfish', '/opt/payara/glassfish/domains']:
      ensure  => 'directory',
      owner   => 'glassfish',
      group   => 'glassfish',
      require => [Group['glassfish'], User['glassfish'], Class['glassfish']]
    }

    mount { '/opt/payara/glassfish/domains':
      ensure  => 'mounted',
      device  => '/data/glassfish',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['glassfishdata'], File['/opt/payara/glassfish/domains']]
    }
  }

  class { 'glassfish':
    install_method      => 'package',
    package_prefix      => 'payara',
    version             => $version,
    manage_accounts     => false,
    create_passfile     => false,
    create_service      => false,
    enable_secure_admin => false,
    manage_java         => false,
    parent_dir          => '/opt',
    install_dir         => 'payara',
    require             => Class['::profiles::java']
  }

  class { 'profiles::glassfish::asadmin_passfile':
    password        => $password,
    master_password => $master_password
  }
}
