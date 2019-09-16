class profiles::glassfish (
  String $flavor = 'payara'
) {

  contain ::profiles
  contain ::profiles::java8

  realize Apt::Source['cultuurnet-tools']
  realize Package['ca-certificates-publiq']

  $version = $flavor ? {
    'payara'    => '4.1.1.171.1',
    'glassfish' => '3.1.2.2'
  }

  class { 'glassfish':
    install_method      => 'package',
    package_prefix      => $flavor,
    version             => $version,
    create_service      => false,
    enable_secure_admin => false,
    manage_java         => false,
    parent_dir          => '/opt',
    install_dir         => $flavor,
    require             => Class['::profiles::java8']
  }

  package { 'mysql-connector-java':
    ensure  => 'latest',
    require => Apt::Source['cultuurnet-tools']
  }

  # Hack to circumvent dependency problems with using glassfish::install_jars
  file { 'mysql-connector-java':
    ensure    => 'link',
    path      => "/opt/${flavor}/glassfish/lib/mysql-connector-java.jar",
    target    => '/opt/mysql-connector-java/mysql-connector-java.jar',
    require   => Class['::glassfish'],
    subscribe => Package['mysql-connector-java']
  }
}
