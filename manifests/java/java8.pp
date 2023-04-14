class profiles::java::java8 inherits ::profiles {

  $javahome = '/usr/lib/jvm/java-8-oracle/jre'

  realize Package['ca-certificates-publiq']
  realize Apt::Source['publiq-tools']

  package { 'oracle-jdk8-archive':
    ensure  => '8u151',
    require => Apt::Source['publiq-tools']
  }

  file { 'oracle-java8-installer.preseed':
    path   => '/var/tmp/oracle-java8-installer.preseed',
    source => 'puppet:///modules/profiles/java/java8/oracle-java8-installer.preseed',
    mode   => '0600',
    backup => false
  }

  package { 'oracle-java8-installer':
    ensure       => '8u151-1~webupd8~0',
    responsefile => '/var/tmp/oracle-java8-installer.preseed',
    require      => [ Package['oracle-jdk8-archive'], File['oracle-java8-installer.preseed']]
  }

  java_ks { "publiq Development CA:${javahome}/lib/security/cacerts":
    certificate  => '/usr/local/share/ca-certificates/publiq/publiq-root-ca.crt',
    password     => 'changeit',
    trustcacerts => true,
    path         => ["${javahome}/bin", '/usr/bin'],
    require      => [Package['oracle-java8-installer'], Package['ca-certificates-publiq']]
  }
}
