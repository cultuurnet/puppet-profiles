class profiles::uitpas::soap (

  Boolean $deployment    = true,
  String $repository             = 'uitpas-soap',
  String $version                = 'latest'
  Boolean $magda_cert_generation = false,
  Boolean $fidus_cert_generation = false,
  Boolean $enable_govdata_soap   = false,

) inherits profiles {
  include profiles::java


    if ($magda_cert_generation) {
    include profiles::uitpas::soap::magda

    Class['profiles::uitpas::soap::magda'] ~> Service['uitpas-soap ']
  }
  if ($fidus_cert_generation) {
    include profiles::uitpas::soap::fidus

    Class['profiles::uitpas::soap::fidus'] ~> Service['uitpas-soap']
  }



  realize Apt::Source[$repository]

    package { 'uitpas-soap':
      ensure  => $version,
      require => Apt::Source[$repository],
      notify  => Service['uitpas-soap'],
  }

  file { '/etc/systemd/system/uitpas-soap.service':
    content => template('profiles/uitpas/soap/soap.service.erb'),
    notify  => [Exec['uitpas-soap-systemd-reload'], Service['uitpas-soap']],
  }

  exec { 'uitpas-soap-systemd-reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  service { 'uitpas-soap':
    ensure     => $deployment_enabled ? {
      true  => 'running',
      false => 'stopped',
    },
    enable     => $deployment_enabled,
    hasstatus  => true,
    hasrestart => true,
    require    => [Class['profiles::java'], Package['uitpas-soap'], File['/etc/systemd/system/uitpas-soap.service']],
  }
}
