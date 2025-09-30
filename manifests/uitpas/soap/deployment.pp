class profiles::uitpas::soap::deployment (
  String $repository             = 'uitpas-soap',
  String $version                = 'latest'

) inherits profiles {
  realize Apt::Source[$repository]

  package { 'uitpas-soap':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => Service['uitpas-soap'],
  }

  systemd::unit_file { 'uitpas-soap.service':
    ensure  => 'running',
    enable  => true,
    content => template('profiles/uitpas/soap/soap.service.erb'),
  }

  service { 'uitpas-soap':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [Class['profiles::java'], Package['uitpas-soap']],
  }
}
