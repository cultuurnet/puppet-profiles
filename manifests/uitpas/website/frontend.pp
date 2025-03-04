class profiles::uitpas::website::frontend (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases       = [],
  Boolean                        $deployment          = true
) inherits ::profiles {

  $basedir = '/var/www/uitpas-website-frontend'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::apache

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']]
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination         => 'http://127.0.0.1:3000/',
    aliases             => $serveraliases
  }

  if $deployment {
    include profiles::uitpas::website::frontend::deployment

    Class['profiles::uitpas::website::frontend::deployment'] -> Apache::Vhost["${servername}_80"]
  }
}
