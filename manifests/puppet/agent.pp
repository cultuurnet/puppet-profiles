class profiles::puppet::agent (
  Optional[String]           $puppetserver   = undef,
  Enum['running', 'stopped'] $service_ensure = 'stopped',
  Boolean                    $service_enable = false
) inherits ::profiles {

  $default_ini_setting_attributes = {
    ensure  => 'present',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    notify  => Service['puppet']
  }

  if $puppetserver {
    ini_setting { 'puppetserver':
      setting => 'server',
      section => 'main',
      value   => $puppetserver,
      *       => $default_ini_setting_attributes
    }

    ini_setting { 'agent puppetserver':
      ensure  => 'absent',
      setting => 'server',
      section => 'agent',
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      notify  => Service['puppet']
    }
  }

  if $facts['ec2_metadata'] {
    ini_setting { 'environment':
      setting => 'environment',
      section => 'main',
      value   => $facts['ec2_tags']['environment'],
      *       => $default_ini_setting_attributes
    }

    ini_setting { 'environment':
      ensure  => 'absent',
      setting => 'environment',
      section => '',
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      notify  => Service['puppet']
    }
  }

  ini_setting { 'agent certificate_revocation':
    setting => 'certificate_revocation',
    section => 'agent',
    value   => false,
    *       => $default_ini_setting_attributes
  }

  ini_setting { 'agent usecacheonfailure':
    setting => 'usecacheonfailure',
    section => 'agent',
    value   => false,
    *       => $default_ini_setting_attributes
  }

  ini_setting { 'agent preferred_serialization_format':
    setting => 'preferred_serialization_format',
    section => 'agent',
    value   => 'pson',
    *       => $default_ini_setting_attributes
  }

  service { 'puppet':
    ensure    => $service_ensure,
    enable    => $service_enable,
    hasstatus => true
  }
}
