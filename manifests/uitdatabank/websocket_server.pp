class profiles::uitdatabank::websocket_server (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases   = [],
  Boolean                       $deployment      = true,
  Stdlib::IP::Address::V4       $service_address = '127.0.0.1',
  Integer                       $service_port    = 3000,
) inherits ::profiles {

  $basedir = '/var/www/udb3-websocket-server'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::nodejs
  include ::profiles::redis
  include ::profiles::apache

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data'], Class['profiles::apache']]
  }

  if $deployment {
    class { 'profiles::uitdatabank::websocket_server::deployment':
      service_address => $service_address,
      service_port    => $service_port,
      require         => [Class['profiles::nodejs'], Class['profiles::redis']],
      before          => Profiles::Apache::Vhost::Reverse_proxy["http://${servername}"]
    }
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    aliases            => $serveraliases,
    destination        => "http://${service_address}:${service_port}/",
    support_websockets => true
  }

  # include ::profiles::uitdatabank::websocket_server::monitoring
  # include ::profiles::uitdatabank::websocket_server::metrics
  # include ::profiles::uitdatabank::websocket_server::logging
}
