class profiles::uitpas::segmentatie (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases   = [],
  Boolean                       $deployment      = true
) inherits ::profiles {

  $basedir = '/var/www/segmentatie'

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
    include profiles::uitpas::segmentatie::deployment
  }

  profiles::apache::vhost::basic { "http://${servername}":
    documentroot  => $basedir,
    serveraliases => $serveraliases
  }
}
