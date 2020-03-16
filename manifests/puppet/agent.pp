class profiles::puppet::agent {

  contain ::profiles

  ini_setting { 'agent certificate_revocation':
    ensure  => 'present',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'agent',
    setting => 'certificate_revocation',
    value   => 'false',
    notify  => Service['puppet']
  }

  service { 'puppet':
    ensure    => 'running',
    enable    => true,
    hasstatus => true
  }
}
