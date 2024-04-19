class profiles::publiq::versions (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases   = [],
  Stdlib::Ipv4                   $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged     $service_port    = 3000,
  Boolean                        $deployment      = true
) inherits ::profiles {

  include profiles::ruby

  if $deployment {
    include profiles::publiq::versions::deployment

    Class['profiles::ruby'] -> Class['profiles::publiq::versions::deployment']
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination => "http://${service_address}:${service_port}/",
    aliases     => $serveraliases
  }

  # include ::profiles::publiq::versions::monitoring
  # include ::profiles::publiq::versions::metrics
  # include ::profiles::publiq::versions::backup
  # include ::profiles::publiq::versions::logging
}
