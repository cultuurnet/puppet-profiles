class profiles::uit::api (
  String                        $servername,
  String                        $database_password,
  Variant[String,Array[String]] $serveraliases     = [],
  Boolean                       $deployment        = true,
  Integer                       $service_port      = 4000
) inherits ::profiles {

  $basedir       = '/var/www/uit-api'
  $database_name = 'uit_api'
  $database_user = 'uit_api'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::nodejs
  include ::profiles::redis
  include ::profiles::mysql::server

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']]
  }

  file { 'uit-api-log':
    ensure  => 'directory',
    path    => "${basedir}/log",
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data'], File[$basedir]]
  }

  mysql_database { $database_name:
    charset => 'utf8mb4',
    collate => 'utf8mb4_unicode_ci',
    require => Class['profiles::mysql::server']
  }

  profiles::mysql::app_user { $database_user:
    database => $database_name,
    password => $database_password,
    require  => Mysql_database[$database_name]
  }

  if $settings::storeconfigs {
    Profiles::Mysql::App_user <<| database == $database_name and tag == $environment |>>
  }

  if $deployment {
    class { 'profiles::uit::api::deployment':
      service_port => $service_port
    }

    Class['profiles::nodejs'] -> Class['profiles::uit::api::deployment']
    Class['profiles::redis'] -> Class['profiles::uit::api::deployment']
    Class['profiles::mysql::server'] -> Class['profiles::uit::api::deployment']
    File['uit-api-log'] -> Class['profiles::uit::api::deployment']
    Profiles::Mysql::App_user["${database_user}"] -> Class['profiles::uit::api::deployment']
    Class['profiles::uit::api::deployment'] -> Profiles::Apache::Vhost::Reverse_proxy["http://${servername}"]
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination => "http://127.0.0.1:${service_port}/",
    aliases     => $serveraliases
  }

  #class { 'profiles::uit::api::logging':
  #  servername => $servername,
  #  log_type   => ''
  #}

  # include ::profiles::uit::api::monitoring
  # include ::profiles::uit::api::metrics
  # include ::profiles::uit::api::backup
}
