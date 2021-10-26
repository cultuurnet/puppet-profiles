class profiles::java::java8 inherits ::profiles {

  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']

  package { 'oracle-jdk8-archive':
    ensure  => '8u151',
    require => Profiles::Apt::Update['cultuurnet-tools']
  }

  file { 'oracle-java8-installer.preseed':
    path   => '/var/tmp/oracle-java8-installer.preseed',
    source => 'puppet:///modules/profiles/java/java8/oracle-java8-installer.preseed',
    mode   => '0600',
    backup => false,
  }

  package { 'oracle-java8-installer':
    ensure       => '8u151-1~webupd8~0',
    responsefile => '/var/tmp/oracle-java8-installer.preseed',
    require      => [ Package['oracle-jdk8-archive'], File['oracle-java8-installer.preseed']],
  }
}
