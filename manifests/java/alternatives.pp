class profiles::java::alternatives (
  Optional[Integer[8, 11]] $default_version = undef
) inherits ::profiles {

  case $default_version {
    8: {
      $java_home = '/usr/lib/jvm/java-8-oracle'
      $jre_home  = "${java_home}/jre"
    }
    11: {
      $java_home = '/usr/lib/jvm/jdk-11.0.12'
      $jre_home  = $java_home
    }
    default: {
      $java_home = undef
    }
  }

  if $java_home {
    ['java', 'keytool'].each |$command| {
      alternatives { $command:
        path    => "${jre_home}/bin/${command}"
      }
    }

    shellvar { 'JAVA_HOME':
      ensure => 'present',
      target => '/etc/environment',
      value  => $java_home
    }
  }
}
