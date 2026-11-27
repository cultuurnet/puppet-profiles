class profiles::uitdatabank::entry_api (
  String                         $database_password,
  String                         $servername,
  String                         $job_interface_servername,
  Variant[String, Array[String]] $serveraliases                     = [],
  Optional[String]               $uitpas_servername                 = undef,
  String                         $database_host                     = '127.0.0.1',
  Boolean                        $deployment                        = true,
  Enum['instance', 'container']  $type                              = 'instance',
  Boolean                        $data_integration                  = true,
  Boolean                        $catch_mail                        = false,
  Boolean                        $schedule_process_duplicates       = false,
  Boolean                        $schedule_movie_fetcher            = false,
  Boolean                        $schedule_add_trailers             = false,
  Boolean                        $schedule_replay_mismatched_events = false
) inherits ::profiles {

  $basedir       = '/var/www/udb3-backend'
  $database_name = 'uitdatabank'
  $database_user = 'entry_api'

  include profiles::redis

  # The container image brings its own PHP and Prince
  if $type == 'instance' {
    realize Apt::Source['publiq-tools']
    realize Package['prince']

    include profiles::php
  }

  if $database_host == '127.0.0.1' {
    $database_host_remote    = false
    $database_host_available = true

    include profiles::mysql::server

    Class['profiles::mysql::server'] -> Mysql_database[$database_name]
  } else {
    $database_host_remote = true

    class { 'profiles::mysql::remote_server':
      host => $database_host
    }

    if $facts['mysqld_version'] {
      $database_host_available = true
    } else {
      $database_host_available = false
    }
  }

  if $database_host_available {
    mysql_database { $database_name:
      charset => 'utf8mb4',
      collate => 'utf8mb4_0900_ai_ci'
    }

    profiles::mysql::app_user { "${database_user}@${database_name}":
      password => $database_password,
      remote   => $database_host_remote,
      require  => Mysql_database[$database_name]
    }

    if $deployment {
      class { 'profiles::uitdatabank::entry_api::deployment':
        type => $type
      }

      # Its ownership_search password is seeded with the host's private key, so
      # only one node per database can manage it
      if $data_integration {
        class { 'profiles::uitdatabank::entry_api::data_integration':
          database_host => $database_host,
          database_name => $database_name,
          require       => Class['profiles::uitdatabank::entry_api::deployment']
        }
      }

      class { 'profiles::uitdatabank::entry_api::cron':
        type                              => $type,
        schedule_process_duplicates       => $schedule_process_duplicates,
        schedule_movie_fetcher            => $schedule_movie_fetcher,
        schedule_add_trailers             => $schedule_add_trailers,
        schedule_replay_mismatched_events => $schedule_replay_mismatched_events,
        require                           => Class['profiles::uitdatabank::entry_api::deployment']
      }

      Profiles::Mysql::App_user["${database_user}@${database_name}"] -> Class['profiles::uitdatabank::entry_api::deployment']
      Class['profiles::redis'] -> Class['profiles::uitdatabank::entry_api::deployment']

      if $type == 'instance' {
        Class['profiles::php'] ~> Class['profiles::uitdatabank::entry_api::deployment']
      }
    }
  }

  class { 'profiles::uitdatabank::resque_web':
    servername => $job_interface_servername
  }

  if $catch_mail {
    include profiles::mailpit
  }

  $api_key_rewrites = [{
                        comment      => 'Capture apiKey from URL parameters',
                        rewrite_cond => '%{QUERY_STRING} (?:^|&)apiKey=([^&]+)',
                        rewrite_rule => '^ - [E=API_KEY:%1]'
                      }, {
                        comment      => 'Capture apiKey from X-Api-Key header',
                        rewrite_cond => '%{HTTP:X-Api-Key} ^.+',
                        rewrite_rule => '^ - [E=API_KEY:%{HTTP:X-Api-Key}]'
                      }, {
                        comment      => 'Capture clientId from URL parameters',
                        rewrite_cond => '%{QUERY_STRING} (?:^|&)clientId=([^&]+)',
                        rewrite_rule => '^ - [E=CLIENT_ID:%1]'
                      }, {
                        comment      => 'Capture clientId from X-Client-Id header',
                        rewrite_cond => '%{HTTP:X-Client-Id} ^.+',
                        rewrite_rule => '^ - [E=CLIENT_ID:%{HTTP:X-Client-Id}]'
                      }, {
                        comment      => 'Capture JWT token from Authorization header',
                        rewrite_cond => '%{HTTP:Authorization} "^Bearer (.+)"',
                        rewrite_rule => '^ - [E=JWT_TOKEN:%1]'
                      }]

  case $type {
    'container': {
      # nocanon and preserve_host hand the request to the app as the php_fpm vhost
      # does: encoded slashes untouched and the original Host header
      profiles::apache::vhost::reverse_proxy { "http://${servername}":
        destination           => 'http://127.0.0.1:8080/',
        aliases               => $serveraliases,
        access_log_format     => 'api_key_json',
        allow_encoded_slashes => 'nodecode',
        proxy_keywords        => 'nocanon',
        preserve_host         => true,
        additional_rewrites   => $api_key_rewrites
      }
    }
    'instance': {
      profiles::apache::vhost::php_fpm { "http://${servername}":
        basedir               => $basedir,
        public_web_directory  => 'web',
        aliases               => $serveraliases,
        access_log_format     => 'api_key_json',
        allow_encoded_slashes => 'nodecode',
        rewrites              => $api_key_rewrites
      }
    }
  }

  profiles::apache::vhost::reverse_proxy { "http://${uitpas_servername}":
    destination => "https://${servername}/uitpas/"
  }

  class { 'profiles::uitdatabank::entry_api::logging':
    servername => $servername
  }
}
