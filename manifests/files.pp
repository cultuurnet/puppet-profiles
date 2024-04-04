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
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    require => File['/data']
  }
}
