class profiles::apache (
  Enum['event', 'itk', 'peruser', 'prefork', 'worker']  $mpm_module        = 'prefork',
  Boolean                                               $mpm_enable        = true,
  Hash                                                  $mpm_module_config = {},
  Hash                                                  $log_formats       = {},
  Boolean                                               $metrics           = true,
  Enum['running', 'stopped']                            $service_status    = 'running'
) inherits ::profiles {

  $default_log_formats = {
    'combined_json' => '{ \"client_ip\": \"%a\", \"remote_logname\": \"%l\", \"user\": \"%u\", \"time\": \"%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t\", \"request\": \"%r\", \"status\": %>s, \"response_bytes\": %b, \"referer\": \"%{Referer}i\", \"user_agent\": \"%{User-Agent}i\" }'
  }

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
    log_formats    => $default_log_formats + $log_formats,
    require        => [Group['www-data'], User['www-data']]
  }

  if $mpm_enable {
    class { "apache::mod::${mpm_module}":
      * => $mpm_module_config
    }
  }

  if $metrics {
    include profiles::apache::metrics
  }

  include profiles::apache::logging

  apache::mod { 'unique_id': }
}
