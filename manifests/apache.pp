class profiles::apache (
  Boolean $metrics = true
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  class { '::apache':
    mpm_module   => 'prefork',
    manage_group => false,
    manage_user  => false,
    require      => [Group['www-data'], User['www-data']]
  }

  if $metrics {
    include profiles::apache::metrics
  }

  apache::mod { 'headers': }
  apache::mod { 'unique_id': }
}
