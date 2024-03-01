class profiles::uitpas::api (
  String                     $database_password,
  String                     $database_host     = '127.0.0.1',
  Boolean                    $deployment        = true,
  Boolean                    $jmx               = true,
  Integer                    $portbase          = 4800,
  Enum['running', 'stopped'] $service_status    = 'running',
  Hash                       $settings          = {}
) inherits ::profiles {

  # (x) mysql server if 127.0.0.1
  # (x) jdbc resource
  # (x) jdbc connection pool
  # (x) glassfish
  # (x) domain uitpas
  # (x) service alias
  # (x) firewall rules (portbase)
  # (x) lvm
  # jvmoptions + restart
  # (x) set
  # (x) system properties
  # (x) service

  $database_name = 'uitpas_api'
  $database_user = 'uitpas_api'
  $passwordfile  = '/home/glassfish/asadmin.pass'

  include ::profiles::java
  include ::profiles::glassfish

  if $database_host == '127.0.0.1' {
    include ::profiles::mysql::server

    Class['profiles::mysql::server'] -> Mysql_database[$database_name]
  }

  realize Group['glassfish']
  realize User['glassfish']

  realize Apt::Source['publiq-tools']
  realize Package['liquibase']
  realize Package['mysql-connector-j']

  mysql_database { $database_name:
    charset => 'utf8mb4',
    collate => 'utf8mb4_unicode_ci'
  }

  profiles::mysql::app_user { $database_user:
    database => $database_name,
    password => $database_password,
    require  => Mysql_database[$database_name]
  }

  profiles::glassfish::domain { 'uitpas':
    portbase       => $portbase,
    jmx            => $jmx,
    service_status => $service_status,
    require        => Class['profiles::glassfish'],
    notify         => Service['uitpas']
  }

  jdbcconnectionpool { 'mysql_uitpas_api_j2eePool':
    ensure       => 'present',
    user         => 'glassfish',
    passwordfile => $passwordfile,
    portbase     => String($portbase),
    resourcetype => 'javax.sql.DataSource',
    dsclassname  => 'com.mysql.jdbc.jdbc2.optional.MysqlDataSource',
    properties   => {
                      'serverName'        => $database_host,
                      'portNumber'        => '3306',
                      'databaseName'      => $database_name,
                      'User'              => $database_user,
                      'Password'          => $database_password,
                      'URL'               => "jdbc:mysql://${database_host}:3306/${database_name}",
                      'driverClass'       => 'com.mysql.jdbc.Driver',
                      'characterEncoding' => 'UTF-8',
                      'useUnicode'        => true,
                      'useSSL'            => false
                    },
    require      => [Profiles::Glassfish::Domain['uitpas'], Profiles::Mysql::App_user['uitpas_api']]
  }

  jdbcresource { 'jdbc/cultuurnet_uitpas':
    ensure         => 'present',
    portbase       => String($portbase),
    user           => 'glassfish',
    passwordfile   => $passwordfile,
    connectionpool => 'mysql_uitpas_api_j2eePool',
    require        => Jdbcconnectionpool['mysql_uitpas_api_j2eePool']
  }

  set { 'server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping':
    ensure       => 'present',
    value        => 'X-Forwarded-Proto',
    user         => 'glassfish',
    passwordfile => $passwordfile,
    portbase     => String($portbase),
    require      => Profiles::Glassfish::Domain['uitpas'],
    notify       => Service['uitpas']
  }

  $settings.each |$name, $value| {
    systemproperty { $name:
      ensure       => 'present',
      value        => $value,
      user         => 'glassfish',
      passwordfile => $passwordfile,
      portbase     => String($portbase),
      require      => Profiles::Glassfish::Domain['uitpas'],
      notify       => Service['uitpas']
    }
  }

  profiles::glassfish::domain::service_alias { 'uitpas':
    require => Profiles::Glassfish::Domain['uitpas']
  }

  service { 'uitpas':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    require   => Profiles::Glassfish::Domain::Service_alias['uitpas']
  }

  if $deployment {
    class { 'profiles::uitpas::api::deployment':
      database_password => $database_password,
      database_host     => $database_host,
      portbase          => $portbase
    }

    Class['profiles::glassfish'] -> Class['profiles::uitpas::api::deployment']
    Package['liquibase'] -> Class['profiles::uitpas::api::deployment']
    Package['mysql-connector-j'] -> Class['profiles::uitpas::api::deployment']
    Profiles::Mysql::App_user[$database_user] -> Class['profiles::uitpas::api::deployment']
  }

  # include ::profiles::uitpas::api::monitoring
  # include ::profiles::uitpas::api::metrics
  # include ::profiles::uitpas::api::backup
  # include ::profiles::uitpas::api::logging
}
