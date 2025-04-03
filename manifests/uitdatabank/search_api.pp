class profiles::uitdatabank::search_api (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases            = [],
  Optional[String]               $elasticsearch_servername = undef,
  Boolean                        $deployment               = true,
  Boolean                        $data_migration           = false
) inherits ::profiles {

  $basedir = '/var/www/udb3-search-service'

  include profiles::php
  include profiles::redis
  include profiles::elasticsearch

  if $deployment {
    include profiles::uitdatabank::geojson_data::deployment

    class { 'profiles::uitdatabank::search_api::deployment':
      require   => [Class['profiles::redis'], Class['profiles::elasticsearch'], Class['profiles::uitdatabank::geojson_data::deployment']],
      subscribe => Class['profiles::php']
    }

    if $data_migration {
      class { 'profiles::uitdatabank::search_api::data_migration':
        subscribe => [Class['profiles::uitdatabank::geojson_data::deployment'], Class['profiles::uitdatabank::search_api::deployment']]
      }
    }
  }

  profiles::apache::vhost::php_fpm { "http://${servername}":
    basedir              => $basedir,
    public_web_directory => 'web',
    aliases              => $serveraliases,
    access_log_format    => 'api_key_json',
    rewrites             => [{
                              comment      => 'Capture apiKey from URL parameters',
                              rewrite_cond => '%{QUERY_STRING} (?:^|&)apiKey=([^&]+)',
                              rewrite_rule => '^ - [E=API_KEY:%1]'
                            }, {
                              comment      => 'Capture apiKey from X-Api-Key header',
                              rewrite_cond => '%{HTTP:X-Api-Key} ^.+',
                              rewrite_rule => '^ - [E=API_KEY:%{HTTP:X-Api-Key}]'
                            }]
  }

  if $elasticsearch_servername {
    profiles::apache::vhost::reverse_proxy { "http://${elasticsearch_servername}":
      destination => 'http://127.0.0.1:9200/'
    }
  }

  class { 'profiles::uitdatabank::search_api::logging':
    servername => $servername
  }

  # include ::profiles::uitdatabank::search_api::monitoring
  # include ::profiles::uitdatabank::search_api::metrics
  # include ::profiles::uitdatabank::search_api::backup
}
