class profiles::puppet::agent (
  String                     $version        = 'installed',
  Optional[String]           $puppetserver   = undef,
  Enum['running', 'stopped'] $service_status = 'stopped'
) inherits ::profiles {

  $default_ini_setting_attributes = {
                                      path    => '/etc/puppetlabs/puppet/puppet.conf',
                                      notify  => Service['puppet']
                                    }

  realize Apt::Source['puppet']

  package { 'puppet-agent':
    ensure  => $version,
    require => Apt::Source['puppet'],
    notify  => Service['puppet']
  }

  if $puppetserver {
    ini_setting { 'puppetserver':
      ensure  => 'present',
      setting => 'server',
      section => 'main',
      value   => $puppetserver,
      *       => $default_ini_setting_attributes
    }
  } else {
    ini_setting { 'puppetserver':
      ensure  => 'absent',
      setting => 'server',
      section => 'main',
      *       => $default_ini_setting_attributes
    }
  }

  if $facts['ec2_metadata'] {
    ini_setting { 'environment':
      ensure  => 'present',
      setting => 'environment',
      section => 'main',
      value   => $trusted['extensions']['pp_environment'],
      *       => $default_ini_setting_attributes
    }
  }

  ini_setting { 'agent certificate_revocation':
    ensure  => 'present',
    setting => 'certificate_revocation',
    section => 'agent',
    value   => false,
    *       => $default_ini_setting_attributes
  }

  ini_setting { 'agent usecacheonfailure':
    ensure  => 'present',
    setting => 'usecacheonfailure',
    section => 'agent',
    value   => false,
    *       => $default_ini_setting_attributes
  }

  ini_setting { 'agent reports':
    ensure  => 'present',
    setting => 'reports',
    section => 'main',
    value   => 'store',
    *       => $default_ini_setting_attributes
  }

  $service_enable = $service_status ? {
    'running' => true,
    'stopped' => false
  }

  service { 'puppet':
    ensure    => $service_status,
    enable    => $service_enable,
    hasstatus => true
  }
}
