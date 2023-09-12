class profiles::uitpas::balie (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases   = [],
  Boolean                        $deployment      = true,
  Stdlib::Ipv4                   $service_address = '127.0.0.1',
  Integer                        $service_port    = 4000,
) inherits ::profiles {

  include ::profiles::nodejs

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination => "http://${service_address}:${service_port}/",
    aliases     => $serveraliases
  }

  if $deployment {
    class { 'profiles::uitpas::balie::deployment':
      service_address => $service_address,
      service_port    => $service_port
    }

    Class['profiles::nodejs'] -> Class['profiles::uitpas::balie::deployment']
  }

  # include ::profiles::uitpas::balie::monitoring
  # include ::profiles::uitpas::balie::metrics
  # include ::profiles::uitpas::balie::backup
  # include ::profiles::uitpas::balie::logging
}
