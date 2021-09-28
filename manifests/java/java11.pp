class profiles::java::java11 inherits profiles {

  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']

  package { 'jdk-11.0.12':
    ensure  => '11.0.12-1',
    require => Profiles::Apt::Update['cultuurnet-tools']
  }

  alternative_entry { '/usr/lib/jvm/jdk-11.0.12/bin/java':
    ensure   => 'present',
    altname  => 'java',
    priority => 10,
    altlink  => '/usr/bin/java',
    require  => Package['jdk-11.0.12']
  }
}
