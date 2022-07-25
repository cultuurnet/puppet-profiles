class profiles::apache inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  class { '::apache':
    mpm_module   => 'prefork',
    manage_group => false,
    manage_user  => false,
    require      => [Group['www-data'], User['www-data']]
  }
}
