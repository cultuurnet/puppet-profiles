class profiles::projectaanvraag::api (
  String                         $database_password,
  String                         $servername,
  Variant[String, Array[String]] $serveraliases     = [],
  String                         $database_host     = '127.0.0.1',
  Boolean                        $deployment        = true
) inherits ::profiles {

  $basedir                   = '/var/www/projectaanvraag-api'
  $database_name             = 'projectaanvraag'
  $database_user             = 'projectaanvraag'
  $mongodb_database_name     = 'widgets'
  $mongodb_database_user     = 'projectaanvraag'
  $mongodb_database_password = 'projectaanvraag'

  include profiles::redis
  include profiles::mongodb
  include profiles::apache
  include profiles::php

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
      class { 'profiles::projectaanvraag::api::deployment':
        database_name => $database_name
      }

      Profiles::Mysql::App_user["${database_user}@${database_name}"] -> Class['profiles::projectaanvraag::api::deployment']
      Class['profiles::redis'] -> Class['profiles::projectaanvraag::api::deployment']
      Class['profiles::mongodb'] -> Class['profiles::projectaanvraag::api::deployment']
      Class['profiles::php'] ~> Class['profiles::projectaanvraag::api::deployment']
      Mongodb::Db[$mongodb_database_name] -> Class['profiles::projectaanvraag::api::deployment']
    }
  }

  profiles::apache::vhost::php_fpm { "http://${servername}":
    basedir               => $basedir,
    public_web_directory  => 'web',
    aliases               => $serveraliases
  }

  mongodb::db { $mongodb_database_name:
    user     => $mongodb_database_user,
    password => $mongodb_database_password,
    password => $mongodb_password,
    roles    => ['readWrite'],
    require  => Class['profiles::mongodb']
  }
}
