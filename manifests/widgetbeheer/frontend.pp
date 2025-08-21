class profiles::widgetbeheer::frontend (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases = [],
  Boolean                        $deployment    = true
) inherits ::profiles {

  $basedir = '/var/www/widgetbeheer-frontend'

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
    include profiles::widgetbeheer::frontend::deployment
  }

  profiles::apache::vhost::basic { "http://${servername}":
    documentroot  => $basedir,
    serveraliases => $serveraliases,
    rewrites      => {
                       comment      => 'Send all requests through index.html',
                       rewrite_cond => [
                                         "${basedir}%{REQUEST_FILENAME} !-f",
                                         "${basedir}%{REQUEST_FILENAME} !-d"
                                       ],
                       rewrite_rule => '. /index.html [L]'
                     }
  }

  # include ::profiles::widgetbeheer::frontend::monitoring
  # include ::profiles::widgetbeheer::frontend::metrics
  # include ::profiles::widgetbeheer::frontend::logging
}
