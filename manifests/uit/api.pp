class profiles::uit::api (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases     = [],
  String                        $database_password = undef
  Boolean                       $deployment        = true,
  Integer                       $service_port      = 4000
) inherits ::profiles {

  $basedir = '/var/www/uit-api'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::firewall::rules
  include ::profiles::nodejs
  include ::profiles::redis
  include ::profiles::mysql::server
  include ::profiles::apache

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

  mysql_database { 'uit_api':
    charset => 'utf8mb4',
    collate => 'utf8mb4_unicode_ci',
    require => Class['profiles::mysql::server']
  }

  mysql_user { 'uit_api@127.0.0.1':
    ensure        => present,
    password_hash => mysql::password($database_password),
    require       => Class['profiles::mysql::server']
  }

  mysql_user { 'uit_api@%':
    ensure        => present,
    password_hash => mysql::password($database_password),
    require       => Class['profiles::mysql::server']
  }

  mysql_grant { 'uit_api@127.0.0.1/uit_api.*':
    user       => 'uit_api@127.0.0.1',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => 'uit_api.*'
  }

  mysql_grant { 'uit_api@%/uit_api.*':
    user       => 'uit_api@%',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => 'uit_api.*'
  }

  if $deployment {
    class { 'profiles::uit::api::deployment':
      service_port => $service_port
    }

    Class['profiles::nodejs'] -> Class['profiles::uit::api::deployment']
    Class['profiles::redis'] -> Class['profiles::uit::api::deployment']
    Class['profiles::mysql::server'] -> Class['profiles::uit::api::deployment']
    File['uit-api-log'] -> Class['profiles::uit::api::deployment']
    Mysql_database['uit_api'] -> Class['profiles::uit::api::deployment']
    Mysql_user['uit_api@127.0.0.1'] -> Class['profiles::uit::api::deployment']
    Mysql_user['uit_api@%'] -> Class['profiles::uit::api::deployment']
    Mysql_grant['uit_api@127.0.0.1/uit_api.*'] -> Class['profiles::uit::api::deployment']
    Mysql_grant['uit_api@%/uit_api.*'] -> Class['profiles::uit::api::deployment']
    Class['profiles::uit::api::deployment'] -> Profiles::Apache::Vhost::Reverse_proxy["http://${servername}"]
  }

  realize Firewall['300 accept HTTP traffic']

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination => "http://127.0.0.1:${service_port}/",
    aliases     => $serveraliases,
    require     => [File[$basedir], Class['profiles::apache']]
  }

  #class { 'profiles::uit::api::logging':
  #  servername => $servername,
  #  log_type   => ''
  #}

  # include ::profiles::uit::api::monitoring
  # include ::profiles::uit::api::metrics
  # include ::profiles::uit::api::backup
}
