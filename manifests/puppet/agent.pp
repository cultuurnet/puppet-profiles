class profiles::puppet::agent (
  String                     $puppetserver,
  Enum['running', 'stopped'] $ensure = 'running',
  Boolean                    $enable = true
) inherits ::profiles {

  Ini_setting {
    ensure  => 'present',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    notify  => Service['puppet']
  }

  ini_setting { 'puppetserver':
    section => '',
    setting => 'server',
    value   => $puppetserver
  }

  ini_setting { 'agent certificate_revocation':
    section => 'agent',
    setting => 'certificate_revocation',
    value   => false
  }

  ini_setting { 'agent usecacheonfailure':
    section => 'agent',
    setting => 'usecacheonfailure',
    value   => false
  }

  ini_setting { 'agent preferred_serialization_format':
    section => 'agent',
    setting => 'preferred_serialization_format',
    value   => 'pson'
  }

  service { 'puppet':
    ensure    => $ensure,
    enable    => $enable,
    hasstatus => true
  }
}
