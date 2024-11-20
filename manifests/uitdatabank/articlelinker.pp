class profiles::uitdatabank::articlelinker (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases   = [],
  Boolean                       $deployment      = true,
  Stdlib::IP::Address::V4       $service_address = '127.0.0.1',
  Integer                       $service_port    = 5000,
) inherits ::profiles {

  $basedir = '/var/www/uit-articlelinker'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::nodejs
  include ::profiles::apache

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data'], Class['profiles::apache']]
  }

  if $deployment {
    class { 'profiles::uitdatabank::articlelinker::deployment':
      service_address => $service_address,
      service_port    => $service_port,
      require         => Class['profiles::nodejs'],
      before          => Profiles::Apache::Vhost::Reverse_proxy["http://${servername}"]
    }
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    aliases     => $serveraliases,
    destination => "http://${service_address}:${service_port}/"
  }

  # include ::profiles::uitdatabank::articlelinker::monitoring
  # include ::profiles::uitdatabank::articlelinker::metrics
  # include ::profiles::uitdatabank::articlelinker::logging
}
