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
    include profiles::uitpas::cid_web::deployment
  }

  profiles::apache::vhost::basic { "http://${servername}":
    documentroot  => $basedir,
    serveraliases => $serveraliases,
    directories   => {
                       path     => '/config.json',
                       provider => 'files',
                       headers  => [
                                     'set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"',
                                     'set Pragma "no-cache"',
                                     'set Expires "Wed, 1 Jan 1970 00:00:00 GMT"'
                                   ]
                     }
  }
}
