class profiles::publiq::versions (
  Stdlib::Httpurl            $url,
  String                     $certificate,
  String                     $private_key,
  String                     $puppetdb_url,
  Boolean                    $deployment      = true,
  Stdlib::Ipv4               $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged $service_port    = 3000,
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  include profiles::ruby

  include profiles::publiq::versions::service

  profiles::puppetdb::cli::config { 'www-data':
    server_urls => $puppetdb_url,
    certificate => $certificate,
    private_key => $private_key,
    require     => [Group['www-data'], User['www-data']]
  }

  if $deployment {
    class { 'profiles::publiq::versions::deployment':
      service_address => $service_address,
      service_port    => $service_port,
      puppetdb_url    => $puppetdb_url,
      require         => [Group['www-data'], User['www-data'], Class['profiles::ruby']]
    }

    Profiles::Puppetdb::Cli::Config['www-data'] ~> Class['profiles::publiq::versions::service']
  }

  profiles::apache::vhost::reverse_proxy { $url:
    destination => "http://${service_address}:${service_port}/"
  }

  # include ::profiles::publiq::versions::monitoring
  # include ::profiles::publiq::versions::metrics
  # include ::profiles::publiq::versions::backup
  # include ::profiles::publiq::versions::logging
}
