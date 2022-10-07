class profiles::puppet::agent (
  String                     $puppetserver,
  Enum['running', 'stopped'] $ensure = 'running',
  Boolean                    $enable = true
) inherits ::profiles {

  Ini_setting {
    ensure  => 'present',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'agent',
    notify  => Service['puppet']
  }

  ini_setting { 'puppetserver':
    setting => 'server',
    value   => $puppetserver
  }

  ini_setting { 'agent certificate_revocation':
    setting => 'certificate_revocation',
    value   => false
  }

  ini_setting { 'agent usecacheonfailure':
    setting => 'usecacheonfailure',
    value   => false
  }

  ini_setting { 'agent preferred_serialization_format':
    setting => 'preferred_serialization_format',
    value   => 'pson'
  }

  service { 'puppet':
    ensure    => $ensure,
    enable    => $enable,
    hasstatus => true
  }
}
