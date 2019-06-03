class profiles::glassfish {

  contain ::profiles

  realize Apt::Source['cultuurnet-tools']

  contain profiles::java8

  class { 'glassfish':
    install_method      => 'package',
    package_prefix      => 'payara',
    version             => '4.1.1.171.1',
    create_service      => false,
    enable_secure_admin => false,
    manage_java         => false,
    parent_dir          => '/opt',
    install_dir         => 'payara',
    require             => Class['profiles::java8']
  }

  package { 'mysql-connector-java':
    ensure => 'latest'
  }

  # Hack to circumvent dependency problems with using glassfish::install_jars
  file { 'mysql-connector-java':
    ensure    => 'link',
    path      => '/opt/payara/glassfish/lib/mysql-connector-java.jar',
    target    => '/opt/mysql-connector-java/mysql-connector-java.jar',
    require   => Class['glassfish'],
    subscribe => Package['mysql-connector-java']
  }
}
