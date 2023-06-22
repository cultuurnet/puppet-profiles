class profiles::uitpas_cid_logs (
  Stdlib::Httpurl            $url             = 'http://cidlogs.publiq.be',
  Stdlib::Ipv4               $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged $service_port    = 8080,
) inherits ::profiles {

  profiles::apache::vhost::reverse_proxy { $url:
    destination => "http://${service_address}:${service_port}/"
  }
}
