class profiles::uitdatabank::entry_api (
  String  $database_password,
  String  $job_interface_servername,
  String  $database_host            = '127.0.0.1',
  Boolean $deployment               = true
) inherits ::profiles {

  $database_name = 'uitdatabank'
  $database_user = 'entry_api'

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
      include profiles::uitdatabank::entry_api::deployment

      class { 'profiles::uitdatabank::entry_api::data_integration':
        database_name => $database_name
      }

      Profiles::Mysql::App_user["${database_user}@${database_name}"] -> Class['profiles::uitdatabank::entry_api::deployment']
      Class['profiles::uitdatabank::entry_api::deployment'] -> Class['profiles::uitdatabank::entry_api::data_integration']
    }
  }

  class { 'profiles::uitdatabank::resque_web':
    servername => $job_interface_servername
  }
}
