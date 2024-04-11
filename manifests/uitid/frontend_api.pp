class profiles::uitid::frontend_api (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases   = [],
  Boolean                       $deployment      = true,
  Stdlib::Ipv4                  $service_address = '127.0.0.1',
  Integer                       $service_port    = 4000
) inherits ::profiles {

  $basedir = '/var/www/uitid-frontend-api'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::nodejs
  include ::profiles::apache

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']]
  }

  if $deployment {
    class { 'profiles::uitid::frontend_api::deployment':
      service_address => $service_address,
      service_port    => $service_port
    }

    Class['profiles::nodejs'] -> Class['profiles::uitid::frontend_api::deployment']
    Class['profiles::uitid::frontend_api::deployment'] -> Profiles::Apache::Vhost::Reverse_proxy["http://${servername}"]
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    aliases     => $serveraliases,
    destination => "http://${service_address}:${service_port}/",
    require     => [Class['profiles::apache'], File['/var/www/uitid-frontend-api']]
  }

  # include ::profiles::uitid::frontend_api::logging
  # include ::profiles::uitid::frontend_api::monitoring
  # include ::profiles::uitid::frontend_api::metrics
  # include ::profiles::uitid::frontend_api::backup
}
