class profiles::apache (
  Enum['event', 'itk', 'peruser', 'prefork', 'worker']  $mpm_module        = 'prefork',
  Hash                                                  $mpm_module_config = {},
  Boolean                                               $http2             = false,
  Boolean                                               $metrics           = true,
  Enum['running', 'stopped']                            $service_status    = 'running',
) inherits ::profiles {

  if ($mpm_module == 'prefork' and $http2) {
    fail('The HTTP/2 protocol is not supported with MPM module prefork')
  }

  include profiles::apache::logformats

  realize Group['www-data']
  realize User['www-data']

  class { '::apache':
    default_mods          => false,
    mpm_module            => false,
    manage_group          => false,
    manage_user           => false,
    default_vhost         => true,
    protocols             => $http2 ? {
                               true  => ['h2c', 'http/1.1'],
                               false => ['http/1.1']
                             },
    protocols_honor_order => true,
    service_manage        => true,
    service_ensure        => $service_status,
    service_enable        => $service_status ? {
                               'running' => true,
                               'stopped' => false
                             },
    log_formats           => $profiles::apache::logformats::all,
    require               => [Group['www-data'], User['www-data']]
  }

  if $http2 {
    include apache::mod::http2
  }

  class { "apache::mod::${mpm_module}":
    * => $mpm_module_config
  }

  if $metrics {
    include profiles::apache::metrics
  }

  include profiles::apache::logging

  apache::mod { 'unique_id': }
  apache::mod { 'deflate': }
  apache::mod { 'dir': }
}
