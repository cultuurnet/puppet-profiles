class profiles::publiq::versions (
  Boolean                    $deployment      = true,
  Stdlib::Ipv4               $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged $service_port    = 3000,
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  include profiles::ruby

  if $deployment {
    class { 'profiles::publiq::versions::deployment':
      service_address => $service_address,
      service_port    => $service_port,
      require         => [Group['www-data'], User['www-data'], Class['profiles::ruby']]
    }
  }

  profiles::apache::vhost::reverse_proxy { 'http://versions.publiq.be':
    destination => "http://${service_address}:${service_port}/"
  }

  # include ::profiles::publiq::versions::monitoring
  # include ::profiles::publiq::versions::metrics
  # include ::profiles::publiq::versions::backup
  # include ::profiles::publiq::versions::logging
}
