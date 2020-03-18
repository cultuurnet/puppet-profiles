class profiles::puppet::agent {

  contain ::profiles

  Ini_setting {
    ensure  => 'present',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    notify  => Service['puppet']
  }

  ini_setting { 'agent certificate_revocation':
    section => 'agent',
    setting => 'certificate_revocation',
    value   => 'false'
  }

  ini_setting { 'agent usecacheonfailure':
    section => 'agent',
    setting => 'usecacheonfailure',
    value   => 'false'
  }

  service { 'puppet':
    ensure    => 'running',
    enable    => true,
    hasstatus => true
  }
}
