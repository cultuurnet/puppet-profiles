class profiles::files inherits ::profiles {

  @file { '/var/www':
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    require => [Group['www-data'], User['www-data']]
  }

  @file { '/data':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  @file { '/data/backup':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/data']
  }

  @file { '/etc/gcloud':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  @file { '/etc/puppetlabs':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  @file { '/etc/puppetlabs/facter':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    require => File['/etc/puppetlabs']
  }

  @file { '/etc/puppetlabs/facter/facts.d':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/etc/puppetlabs/facter']
  }

  # Realize a list of 'default' files on all servers
  realize File['/data']

  realize File['/etc/puppetlabs']
  realize File['/etc/puppetlabs/facter']
  realize File['/etc/puppetlabs/facter/facts.d']
}
