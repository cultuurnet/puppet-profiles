class profiles::java8 {

  contain ::profiles

  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['cultuurnet-tools']

  package { 'oracle-jdk8-archive':
    ensure  => '8u151',
    require => Profiles::Apt::Update['cultuurnet-tools']
  }

  file { 'oracle-java8-installer.preseed':
    path   => '/var/tmp/oracle-java8-installer.preseed',
    source => 'puppet:///modules/profiles/java8/oracle-java8-installer.preseed',
    mode   => '0600',
    backup => false,
  }

  package { 'oracle-java8-installer':
    ensure       => '8u151-1~webupd8~0',
    responsefile => '/var/tmp/oracle-java8-installer.preseed',
    require      => [ Package['oracle-jdk8-archive'], File['oracle-java8-installer.preseed']],
  }

  shellvar { 'JAVA_HOME':
    ensure => 'present',
    target => '/etc/environment',
    value  => '/usr/lib/jvm/java-8-oracle'
  }
}
