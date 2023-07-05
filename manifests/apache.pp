class profiles::apache (
  Boolean                    $metrics        = true,
  Enum['running', 'stopped'] $service_status = 'running'
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  class { '::apache':
    mpm_module     => 'prefork',
    manage_group   => false,
    manage_user    => false,
    default_vhost  => true,
    service_manage => true,
    service_ensure => $service_status,
    service_enable => $service_status ? {
                        'running' => true,
                        'stopped' => false
                      },
    require        => [Group['www-data'], User['www-data']]
  }

  if $metrics {
    include profiles::apache::metrics
  }

  apache::mod { 'unique_id': }
}
