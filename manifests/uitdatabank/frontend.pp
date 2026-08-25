class profiles::uitdatabank::frontend (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases   = [],
  Boolean                       $deployment      = true,
  Enum['instance', 'container']  $type           = 'instance',
  Stdlib::IP::Address::V4       $service_address = '127.0.0.1',
  Integer                       $service_port    = 4000,
) inherits ::profiles {

  $basedir = '/var/www/udb3-frontend'

  include ::profiles::apache

  case $type {
    'instance': {
      realize Group['www-data']
      realize User['www-data']

      include ::profiles::nodejs

      file { $basedir:
        ensure  => 'directory',
        owner   => 'www-data',
        group   => 'www-data',
        require => [Group['www-data'], User['www-data'], Class['profiles::apache']]
      }

      $deployment_require = Class['profiles::nodejs']
    }
    'container': {
      $deployment_require = Class['profiles::apache']
    }
  }

  if $deployment {
    class { 'profiles::uitdatabank::frontend::deployment':
      service_address => $service_address,
      service_port    => $service_port,
      require         => $deployment_require,
      before          => Profiles::Apache::Vhost::Reverse_proxy["http://${servername}"]
    }
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    aliases     => $serveraliases,
    destination => "http://${service_address}:${service_port}/"
  }

  # include ::profiles::uitdatabank::frontend::monitoring
  # include ::profiles::uitdatabank::frontend::metrics
  # include ::profiles::uitdatabank::frontend::logging
}
