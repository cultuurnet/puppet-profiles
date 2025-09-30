class profiles::uitpas::soap::deployment (
  String $repository             = 'uitpas-soap',
  String $version                = 'latest',
  Hash $env_settings             = {},

) inherits profiles {
  realize Apt::Source[$repository]

  package { 'uitpas-soap':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => Service['uitpas-soap'],
  }
   file { '/opt/uitpas-soap/env.properties':
      ensure  => 'file',
      content => template('profiles/uitpas/soap/env.properties.erb'),
      owner   => 'glassfish',
      group   => 'glassfish',
      mode    => '0644'    }

  systemd::unit_file { 'uitpas-soap.service':
    ensure  => 'file',
    content => template('profiles/uitpas/soap/soap.service.erb')
  }

  service { 'uitpas-soap':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    require    => [Class['profiles::java'], Package['uitpas-soap'], File['/opt/uitpas-soap/env.properties']],
  }
}
