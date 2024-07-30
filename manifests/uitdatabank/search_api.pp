class profiles::uitdatabank::search_api (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases     = [],
  Boolean                        $deployment        = true,
  Boolean                        $data_migration    = false
) inherits ::profiles {

  $basedir = '/var/www/udb3-search-service'

  include profiles::php
  include profiles::elasticsearch

  if $deployment {
    include profiles::uitdatabank::geojson_data::deployment

    class { 'profiles::uitdatabank::search_api::deployment':
      basedir => $basedir,
      require => Class['profiles::uitdatabank::geojson_data::deployment']
    }

    if $data_migration {
      class { 'profiles::uitdatabank::search_api::data_migration':
        basedir   => $basedir,
        subscribe => [Class['profiles::uitdatabank::geojson_data::deployment'], Class['profiles::uitdatabank::search_api::deployment']]
      }
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

  class { 'profiles::uitdatabank::search_api::logging':
    servername => $servername
  }

  # include ::profiles::uitdatabank::search_api::monitoring
  # include ::profiles::uitdatabank::search_api::metrics
  # include ::profiles::uitdatabank::search_api::backup
}
