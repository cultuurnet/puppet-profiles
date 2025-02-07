class profiles::uitdatabank::jwt_provider (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases = [],
  Boolean                        $deployment    = true
) inherits ::profiles {

  $basedir = '/var/www/jwt-provider'

  include profiles::php
  include profiles::apache

  if $deployment {
    class { 'profiles::uitdatabank::jwt_provider::deployment':
      require => Class['profiles::php']
    }
  }

  profiles::apache::vhost::php_fpm { "http://${servername}":
    basedir              => $basedir,
    public_web_directory => 'web',
    aliases              => $serveraliases,
    access_log_format    => 'apikey_json',
    rewrites             => [ {
                                comment      => 'Capture apiKey from URL parameters',
                                rewrite_cond => '%{QUERY_STRING} (?:^|&)apiKey=([^&]+)',
                                rewrite_rule => '^ - [E=APIKEY:%1]'
                              }, {
                                comment      => 'Capture apiKey from X-Api-Key header',
                                rewrite_cond => '%{HTTP:X-Api-Key} ^.+',
                                rewrite_rule => '^ - [E=APIKEY:%{HTTP:X-Api-Key}]'
                             } ]
  }

  # include ::profiles::uitdatabank::jwt_provider::logging
  # include ::profiles::uitdatabank::jwt_provider::monitoring
  # include ::profiles::uitdatabank::jwt_provider::metrics
  # include ::profiles::uitdatabank::jwt_provider::backup
}
