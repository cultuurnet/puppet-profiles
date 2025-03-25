class profiles::uitpas::cid_web (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases   = [],
  Boolean                       $deployment      = true
) inherits ::profiles {

  $basedir = '/var/www/uitpas-cid-web'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::apache

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data'], Class['profiles::apache']]
  }

  if $deployment {
    class { 'profiles::uitpas::cid_web::deployment':
      service_address => $service_address,
      service_port    => $service_port,
      require         => Class['profiles::nodejs'],
      before          => Profiles::Apache::Vhost::Reverse_proxy["http://${servername}"]
    }
  }

  profiles::apache::vhost::basic { "http://${servername}":
    documentroot  => $basedir,
    serveraliases => $serveraliases
  }
}
