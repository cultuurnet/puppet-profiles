class profiles::apache (
  Enum['event', 'itk', 'peruser', 'prefork', 'worker']  $mpm_module        = 'prefork',
  Hash                                                  $mpm_module_config = {},
  Boolean                                               $metrics           = true,
  Enum['running', 'stopped']                            $service_status    = 'running'
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  class { '::apache':
    mpm_module     => false,
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

  class { "apache::mod::${mpm_module}":
    * => $mpm_module_config
  }

  if $metrics {
    include profiles::apache::metrics
  }

  include profiles::apache::logging

  apache::mod { 'unique_id': }
}
