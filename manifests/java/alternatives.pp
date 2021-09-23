class profiles::java::alternatives (
  Optional[Integer[8, 11]] $default_version = undef
) inherits profiles {

  $java_home = $default_version ? {
    8       => '/usr/lib/jvm/java-8-oracle',
    11      => '/usr/lib/jvm/jdk-11.0.12',
    default => undef
  }

  if $java_home {
    alternatives { 'java':
      path    => "${java_home}/bin/java"
    }

    shellvar { 'JAVA_HOME':
      ensure => 'present',
      target => '/etc/environment',
      value  => $java_home
    }
  }
}
