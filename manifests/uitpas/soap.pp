class profiles::uitpas::soap (

  Boolean $deployment_enabled = true,
  String $repository = 'uitpas-soap',
  String $version = 'latest'

) inherits profiles {
  include profiles::java
  realize Apt::Source[$repository]

  if ($deployment_enabled) {
    package { 'uitpas-soap':
      ensure  => $version,
      require => Apt::Source[$repository],
      notify  => Service['uitpas-soap'],
    }
  }

  service { 'uitpas-soap':
    ensure     => $deployment_enabled ? {
      true  => 'running',
      false => 'stopped',
    },
    enable     => $deployment_enabled,
    hasstatus  => true,
    hasrestart => true,
    start      => '/usr/bin/java -jar /opt/uitpas-soap/uitpas-soap.jar',
    require    => [Class['profiles::java'], Package['uitpas-soap']],
  }
}
