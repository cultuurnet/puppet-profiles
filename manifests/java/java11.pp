class profiles::java::java11 inherits ::profiles {

  include ::profiles::packages

  $javahome = '/usr/lib/jvm/jdk-11.0.12'

  realize Apt::Source['cultuurnet-tools']
  realize Package['ca-certificates-publiq']

  package { 'jdk-11.0.12':
    ensure  => '11.0.12-1',
    require => Apt::Source['cultuurnet-tools']
  }

  ['java', 'keytool'].each |$command| {
    alternative_entry { "${javahome}/bin/${command}":
      ensure   => 'present',
      altname  => $command,
      priority => 10,
      altlink  => "/usr/bin/${command}",
      require  => Package['jdk-11.0.12']
    }
  }

  java_ks { "publiq Development CA:${javahome}/lib/security/cacerts":
    certificate  => '/usr/local/share/ca-certificates/publiq/publiq-root-ca.crt',
    password     => 'changeit',
    trustcacerts => true,
    path         => ["${javahome}/bin", '/usr/bin'],
    require      => [Package['jdk-11.0.12'], Package['ca-certificates-publiq']]
  }
}
