class profiles::widgetbeheer::frontend (
  String                         $servername,
  Stdlib::Httpurl                $api_url,
  Variant[String, Array[String]] $serveraliases = [],
  Boolean                        $deployment    = true
) inherits ::profiles {

  $basedir       = '/var/www/widgetbeheer-frontend'
  $api_transport = split($api_url, ':')[0]

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
    documentroot    => $basedir,
    serveraliases   => $serveraliases,
    rewrites        => [{
                         comment      => 'Proxy /upload endpoint to API',
                         rewrite_rule => "^/upload$ ${api_url}/upload [P]"
                       }, {
                         comment      => 'Send all requests through index.html',
                         rewrite_cond => [
                                           "${basedir}%{REQUEST_FILENAME} !-f",
                                           "${basedir}%{REQUEST_FILENAME} !-d"
                                         ],
                         rewrite_rule => '. /index.html [L]'
                       }],
    directories     => [{
                         path     => 'index.html',
                         provider => 'files',
                         headers  => [
                                       'set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"',
                                       'set Pragma "no-cache"',
                                       'set Expires "Wed, 1 Jan 1970 00:00:00 GMT"'
                                     ]
                       }, {
                         path     => 'config.json',
                         provider => 'files',
                         headers  => [
                                       'set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"',
                                       'set Pragma "no-cache"',
                                       'set Expires "Wed, 1 Jan 1970 00:00:00 GMT"'
                                     ]
                       }],
    ssl_proxyengine => $api_transport ? {
                         'https' => true,
                         'http'  => false
                       }
  }

  # include ::profiles::widgetbeheer::frontend::monitoring
  # include ::profiles::widgetbeheer::frontend::metrics
  # include ::profiles::widgetbeheer::frontend::logging
}
