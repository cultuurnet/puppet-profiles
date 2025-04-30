class profiles::uitpas::balie_api (
  String                         $servername,
  String                         $balie_next_url,
  Variant[String, Array[String]] $serveraliases  = [],
  Boolean                        $deployment     = true
) inherits ::profiles {

  $basedir = '/var/www/uitpas-balie-api'

  include profiles::php
  include profiles::apache
  include ::apache::mod::proxy_http

  if $balie_next_url =~ /^https/ {
    $https_destination = true

    include ::apache::mod::ssl
  } else {
    $https_destination = false
  }

  profiles::apache::vhost::php_fpm { "http://${servername}":
    aliases              => $serveraliases,
    basedir              => $basedir,
    public_web_directory => 'web',
    headers              => 'set Cache-Control "no-cache,no-store" "env=legacy_app_path"',
    ssl_proxyengine      => $https_destination,
    directories          => {
                              path     => '/app_v1/index.html',
                              provider => 'files',
                              headers  => [
                                            'set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"',
                                            'set Pragma "no-cache"',
                                            'set Expires "Wed, 1 Jan 1970 00:00:00 GMT"'
                                          ]
                            },
    rewrites             => [
                             {
                               'comment'      => 'Redirect ROOT to angular app with path /app_v1/ if it exists',
                               'rewrite_cond' => '%{DOCUMENT_ROOT}/app_v1 -d',
                               'rewrite_rule' => '^/$ /app_v1/ [R]'
                             }, {
                               'comment'      => 'Set legacy environment variable for all paths starting wit /app_v1/',
                               'rewrite_cond' => '%{REQUEST_URI} ^/app_v1/.*$',
                               'rewrite_rule' => '^ - [E=legacy_app_path]'
                             }, {
                               'comment'      => 'Redirect /mobile to /app/mobile',
                               'rewrite_rule' => '^/mobile /app/mobile [L,R=301]'
                             }, {
                               'comment'      => 'Proxy /app to React app',
                               'rewrite_rule' => "^/app\$ ${balie_next_url}/app [P,L]"
                             }, {
                               'comment'      => 'Proxy /app/ to React app',
                               'rewrite_rule' => "^/app/(.*)\$ ${balie_next_url}/app/\$1 [P,L]"
                             }
                           ]
  }

  if $deployment {
    include profiles::uitpas::balie_api::deployment
  }

  # include ::profiles::uitpas::balie_api::monitoring
  # include ::profiles::uitpas::balie_api::metrics
  # include ::profiles::uitpas::balie_api::backup
  # include ::profiles::uitpas::balie_api::logging
}
