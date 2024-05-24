class profiles::uitid::frontend (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases       = [],
  Boolean                       $deployment          = true,
  Stdlib::IP::Address::V4       $service_address     = '127.0.0.1',
  Integer                       $service_port        = 3000
) inherits ::profiles {

  $basedir = '/var/www/uitid-frontend'

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
    class { 'profiles::uitid::frontend::deployment':
      service_address => $service_address,
      service_port    => $service_port
    }

    Class['profiles::nodejs'] -> Class['profiles::uitid::frontend::deployment']
    Class['profiles::uitid::frontend::deployment'] -> Profiles::Apache::Vhost::Reverse_proxy["http://${servername}"]
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    aliases     => $serveraliases,
    destination => "http://${service_address}:${service_port}/",
    require     => [Class['profiles::apache'], File['/var/www/uitid-frontend']]
  }

  # include ::profiles::uitid::frontend::logging
  # include ::profiles::uitid::frontend::monitoring
  # include ::profiles::uitid::frontend::metrics
  # include ::profiles::uitid::frontend::backup
}
