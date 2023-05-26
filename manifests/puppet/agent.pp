class profiles::puppet::agent (
  String                     $version        = 'installed',
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
  }

  realize Apt::Source['puppet']

  package { 'puppet-agent':
    ensure  => $version,
    require => Apt::Source['puppet'],
    notify  => Service['puppet']
  }

  if $facts['ec2_metadata'] {
    ini_setting { 'environment':
      setting => 'environment',
      section => 'main',
      value   => $facts['ec2_tags']['environment'],
      *       => $default_ini_setting_attributes
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

  ini_subsetting { 'agent reports':
    setting              => 'reports',
    section              => 'main',
    subsetting           => 'store',
    subsetting_separator => ',',
    *                    => $default_ini_setting_attributes
  }

  service { 'puppet':
    ensure    => $service_ensure,
    enable    => $service_enable,
    hasstatus => true
  }
}
