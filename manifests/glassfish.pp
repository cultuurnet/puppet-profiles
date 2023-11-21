class profiles::glassfish (
  String $version         = '4.1.2.181',
  String $password        = 'adminadmin',
  String $master_password = 'changeit'
) inherits ::profiles {

  contain ::profiles::java

  realize Apt::Source['publiq-tools']
  realize Group['glassfish']
  realize User['glassfish']

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
