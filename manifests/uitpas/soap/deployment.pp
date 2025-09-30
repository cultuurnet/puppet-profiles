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

  file { '/etc/systemd/system/uitpas-soap.service':
    content => template('profiles/uitpas/soap/soap.service.erb'),
    notify  => [Exec['uitpas-soap-systemd-reload'], Service['uitpas-soap']],
  }

  exec { 'uitpas-soap-systemd-reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  service { 'uitpas-soap':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => [Class['profiles::java'], Package['uitpas-soap'], File['/etc/systemd/system/uitpas-soap.service']],
  }
}
