class profiles::uitdatabank::angular_app (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases = [],
  Boolean                        $deployment    = true
) inherits ::profiles {

  $basedir = '/var/www/udb3-angular-app'

  realize Group['www-data']
  realize User['www-data']

  include profiles::apache

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data'], Class['profiles::apache']]
  }

  if $deployment {
    include profiles::uitdatabank::angular_app::deployment
  }

  profiles::apache::vhost::basic { "http://${servername}":
    documentroot  => $basedir,
    serveraliases => $serveraliases,
    directories   => [{
                       path     => 'index.html',
                       provider => 'files',
                       headers  => [
                                     'set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"',
                                     'set Pragma "no-cache"',
                                     'set Expires "Wed, 1 Jan 1970 00:00:00 GMT"'
                                   ]
                     }]
  }

  # include ::profiles::uitdatabank::angular_app::monitoring
  # include ::profiles::uitdatabank::angular_app::metrics
  # include ::profiles::uitdatabank::angular_app::logging
}
