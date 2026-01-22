class profiles::puppet::agent (
  String                     $version        = 'installed',
  Optional[String]           $puppetserver   = undef,
  Enum['running', 'stopped'] $service_status = 'stopped'
) inherits ::profiles {

  $default_ini_setting_attributes = {
                                      path   => '/etc/puppetlabs/puppet/puppet.conf',
                                      notify => Service['puppet']
                                    }

  realize Apt::Source['openvox']
  realize File['/etc/puppetlabs/facter/facts.d']

  package { 'openvox-agent':
    ensure  => $version,
    require => [Apt::Source['openvox'], File['/etc/puppetlabs/facter/facts.d']],
    notify  => Service['puppet']
  }

  file { 'puppet agent production environment hiera.yaml':
    ensure  => 'absent',
    path    => '/etc/puppetlabs/code/environments/production/hiera.yaml',
    require => Package['openvox-agent']
  }

  file { 'puppet agent production environment datadir':
    ensure  => 'absent',
    path    => '/etc/puppetlabs/code/environments/production/data',
    force   => true,
    require => Package['openvox-agent']
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

  service { 'puppet':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 }
  }
}
