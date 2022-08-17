class profiles::publiq::versions (
  # Stdlib::Httpurl            $url,
  # Stdlib::Ipv4               $service_address = '127.0.0.1',
  # Stdlib::Port::Unprivileged $service_port    = 3000,
  String                     $url,
  String                     $service_address = '127.0.0.1',
  Integer                    $service_port    = 3000,
  Boolean                    $deployment      = true
) inherits ::profiles {

  include profiles::ruby

  if $deployment {
    include profiles::publiq::versions::deployment

    Class['profiles::ruby'] -> Class['profiles::publiq::versions::deployment']
  }

  profiles::apache::vhost::reverse_proxy { $url:
    destination => "http://${service_address}:${service_port}/"
  }

  # include ::profiles::publiq::versions::monitoring
  # include ::profiles::publiq::versions::metrics
  # include ::profiles::publiq::versions::backup
  # include ::profiles::publiq::versions::logging
}
