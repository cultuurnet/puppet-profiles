class profiles::puppet::puppetserver::puppetdb (
  Optional[Stdlib::Httpurl] $url     = undef,
  Optional[String]          $version = undef
) inherits ::profiles {

  # Setup documented at https://www.puppet.com/docs/puppetdb/7/connect_puppet_server.html

  if $url {
    if $version {
      $termini_version = $version
    } else {
      $termini_version = 'installed'
    }
    $reports      = 'present'
    $storeconfigs = 'present'

    realize Group['puppet']
    realize User['puppet']

    file { 'puppetserver puppetdb.conf':
      ensure  => 'file',
      path    => '/etc/puppetlabs/puppet/puppetdb.conf',
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0644',
      require => [Group['puppet'], User['puppet']]
    }

    ini_setting { 'puppetserver server_urls':
      ensure  => 'present',
      path    => '/etc/puppetlabs/puppet/puppetdb.conf',
      setting => 'server_urls',
      section => 'main',
      value   => $url,
      require => File['puppetserver puppetdb.conf']
    }

    ini_setting { 'puppetserver soft_write_failure':
      ensure  => 'present',
      path    => '/etc/puppetlabs/puppet/puppetdb.conf',
      setting => 'soft_write_failure',
      section => 'main',
      value   => false,
      require => File['puppetserver puppetdb.conf']
    }

    file { 'puppetserver routes.yaml':
      ensure  => 'file',
      path    => '/etc/puppetlabs/puppet/routes.yaml',
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0644',
      source  => 'puppet:///modules/profiles/puppet/puppetserver/routes.yaml',
      require => [Group['puppet'], User['puppet']]
    }
  } else {
    $termini_version = 'absent'
    $reports         = 'absent'
    $storeconfigs    = 'absent'

    file { 'puppetserver puppetdb.conf':
      ensure  => 'absent',
      path    => '/etc/puppetlabs/puppet/puppetdb.conf'
    }

    file { 'puppetserver routes.yaml':
      ensure  => 'absent',
      path    => '/etc/puppetlabs/puppet/routes.yaml'
    }
  }

  package { 'puppetdb-termini':
    ensure => $termini_version
  }

  ini_setting { 'puppetserver reports':
    ensure  => $reports,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    setting => 'reports',
    section => 'server',
    value   => 'store,puppetdb'
  }

  ini_setting { 'puppetserver storeconfigs':
    ensure  => $storeconfigs,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    setting => 'storeconfigs',
    section => 'server',
    value   => true
  }

  ini_setting { 'puppetserver storeconfigs_backend':
    ensure  => $storeconfigs,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    setting => 'storeconfigs_backend',
    section => 'server',
    value   => 'puppetdb'
  }
}
