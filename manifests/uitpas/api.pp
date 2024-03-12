class profiles::uitpas::api (
  String                     $database_password,
  String                     $database_host     = '127.0.0.1',
  Boolean                    $deployment        = true,
  Optional[String]           $initial_heap      = undef,
  Optional[String]           $maximum_heap      = undef,
  Boolean                    $jmx               = true,
  Integer                    $portbase          = 4800,
  Enum['running', 'stopped'] $service_status    = 'running',
  Hash                       $settings          = {}
) inherits ::profiles {

  $database_name      = 'uitpas_api'
  $database_user      = 'uitpas_api'
  $default_attributes = {
                          user         => 'glassfish',
                          passwordfile => '/home/glassfish/asadmin.pass',
                          portbase     => String($portbase)
                        }

  include ::profiles::java
  include ::profiles::glassfish

  if $database_host == '127.0.0.1' {
    include ::profiles::mysql::server

    $database_host_remote    = false
    $database_host_available = true

    Class['profiles::mysql::server'] -> Mysql_database[$database_name]
  } else {
    include ::profiles::mysql::rds

    $database_host_remote = true

    if $facts['mysqld_version'] {
      $database_host_available = true

      Class['profiles::mysql::rds'] -> Mysql_database[$database_name]
    } else {
      $database_host_available = false
    }
  }

  realize Group['glassfish']
  realize User['glassfish']

  realize Apt::Source['publiq-tools']
  realize Package['liquibase']
  realize Package['mysql-connector-j']

  profiles::glassfish::domain { 'uitpas':
    portbase       => $portbase,
    initial_heap   => $initial_heap,
    maximum_heap   => $maximum_heap,
    jmx            => $jmx,
    service_status => $service_status,
    require        => Class['profiles::glassfish'],
    notify         => Service['uitpas']
  }

  if $database_host_available {
    mysql_database { $database_name:
      charset => 'utf8mb4',
      collate => 'utf8mb4_unicode_ci'
    }

    profiles::mysql::app_user { $database_user:
      database => $database_name,
      password => $database_password,
      remote   => $database_host_remote,
      require  => Mysql_database[$database_name]
    }

    jdbcconnectionpool { 'mysql_uitpas_api_j2eePool':
      ensure       => 'present',
      resourcetype => 'javax.sql.DataSource',
      dsclassname  => 'com.mysql.cj.jdbc.MysqlDataSource',
      properties   => {
                        'serverName'        => $database_host,
                        'portNumber'        => '3306',
                        'databaseName'      => $database_name,
                        'User'              => $database_user,
                        'Password'          => $database_password,
                        'URL'               => "jdbc:mysql://${database_host}:3306/${database_name}",
                        'driverClass'       => 'com.mysql.cj.jdbc.Driver',
                        'characterEncoding' => 'UTF-8',
                        'useUnicode'        => true,
                        'useSSL'            => false
                      },
      require      => [Profiles::Glassfish::Domain['uitpas'], Profiles::Mysql::App_user['uitpas_api']],
      *            => $default_attributes
    }

    jdbcresource { 'jdbc/cultuurnet_uitpas':
      ensure         => 'present',
      connectionpool => 'mysql_uitpas_api_j2eePool',
      require        => Jdbcconnectionpool['mysql_uitpas_api_j2eePool'],
      *              => $default_attributes
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
      File['Domain uitpas mysql-connector-j'] -> Class['profiles::uitpas::api::deployment']
      Profiles::Mysql::App_user[$database_user] -> Class['profiles::uitpas::api::deployment']
    }
  }

  set { 'server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping':
    ensure       => 'present',
    value        => 'X-Forwarded-Proto',
    require      => Profiles::Glassfish::Domain['uitpas'],
    notify       => Service['uitpas'],
    *            => $default_attributes
  }

  jvmoption { 'Clear domain uitpas default truststore':
    ensure => 'absent',
    option => '-Djavax.net.ssl.trustStore=\$\{com.sun.aas.instanceRoot\}/config/cacerts.jks',
    require => Profiles::Glassfish::Domain['uitpas'],
    notify => Service['uitpas'],
    *      => $default_attributes
  }

  jvmoption { 'Domain uitpas truststore':
    ensure  => 'present',
    option  => '-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts',
    require => Profiles::Glassfish::Domain['uitpas'],
    notify  => Service['uitpas'],
    *       => $default_attributes
  }

  jvmoption { 'Domain uitpas timezone':
    ensure  => 'present',
    option  => '-Duser.timezone=CET',
    require => Profiles::Glassfish::Domain['uitpas'],
    notify  => Service['uitpas'],
    *       => $default_attributes
  }

  $settings.each |$name, $value| {
    systemproperty { $name:
      ensure  => 'present',
      value   => $value,
      require => Profiles::Glassfish::Domain['uitpas'],
      notify  => Service['uitpas'],
      *       => $default_attributes
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

  file { 'Domain uitpas mysql-connector-j':
    ensure  => 'file',
    path    => '/opt/payara/glassfish/lib/mysql-connector-j.jar',
    source  => '/usr/share/java/mysql-connector-j.jar',
    require => Package['mysql-connector-j'],
    before  => Profiles::Glassfish::Domain['uitpas']
  }

  # include ::profiles::uitpas::api::monitoring
  # include ::profiles::uitpas::api::metrics
  # include ::profiles::uitpas::api::backup
  # include ::profiles::uitpas::api::logging
}
