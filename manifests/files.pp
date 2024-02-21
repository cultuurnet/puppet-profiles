class profiles::files inherits ::profiles {

  @file { '/var/www':
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']]
  }
}
