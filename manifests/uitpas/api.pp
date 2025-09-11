class profiles::uitpas::api (
  String                         $servername,
  String                         $database_password,
  Variant[String, Array[String]] $serveraliases        = [],
  String                         $database_host        = '127.0.0.1',
  Boolean                        $deployment           = true,
  Optional[String]               $initial_heap_size    = undef,
  Optional[String]               $maximum_heap_size    = undef,
  Boolean                        $jmx                  = true,
  Boolean                        $newrelic             = false,
  Optional[String]               $newrelic_license_key = lookup('data::newrelic::license_key', Optional[String], 'first', undef),
  Integer                        $portbase             = 4800,
  Enum['running', 'stopped']     $service_status       = 'running',
  Boolean                        $service_watchdog     = false,
  Hash                           $settings             = {}
) inherits profiles {
  $database_name              = 'uitpas_api'
  $database_user              = 'uitpas_api'
  $glassfish_domain_http_port = $portbase + 80
  $default_attributes         = {
    user         => 'glassfish',
    passwordfile => '/home/glassfish/asadmin.pass',
    portbase     => String($portbase),
  }

  include profiles::apache
  include profiles::java
  include profiles::glassfish

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination => "http://127.0.0.1:${glassfish_domain_http_port}/uitid/rest/",
    aliases     => $serveraliases,
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

  realize Group['glassfish']
  realize User['glassfish']

  realize Apt::Source['publiq-tools']
  realize Package['liquibase']
  realize Package['mysql-connector-j']

  profiles::glassfish::domain { 'uitpas':
    portbase             => $portbase,
    initial_heap_size    => $initial_heap_size,
    maximum_heap_size    => $maximum_heap_size,
    jmx                  => $jmx,
    newrelic             => $newrelic,
    newrelic_app_name    => "uitpas-api-${environment}",
    newrelic_license_key => $newrelic_license_key,
    service_status       => $service_status,
    require              => Class['profiles::glassfish'],
    notify               => Service['uitpas'],
  }

  if $database_host_available {
    mysql_database { $database_name:
      charset => 'utf8mb4',
      collate => 'utf8mb4_unicode_ci',
    }

    profiles::mysql::app_user { "${database_user}@${database_name}":
      password => $database_password,
      remote   => $database_host_remote,
      require  => Mysql_database[$database_name],
    }

    profiles::mysql::app_user { "etl@${database_name}":
      password => lookup('data::mysql::etl::password', Optional[String], 'first', undef),
      readonly => true,
      remote   => $database_host_remote,
      require  => Mysql_database[$database_name],
    }

    profiles::mysql::app_user { "2ndline_ro@${database_name}":
      password => lookup('data::mysql::2ndline_ro::password', Optional[String], 'first', undef),
      readonly => true,
      remote   => $database_host_remote,
      require  => Mysql_database[$database_name],
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
        'useSSL'            => false,
      },
      require      => [Profiles::Glassfish::Domain['uitpas'], Profiles::Mysql::App_user["${database_user}@${database_name}"]],
      *            => $default_attributes,
    }

    jdbcresource { 'jdbc/cultuurnet_uitpas':
      ensure         => 'present',
      connectionpool => 'mysql_uitpas_api_j2eePool',
      require        => Jdbcconnectionpool['mysql_uitpas_api_j2eePool'],
      *              => $default_attributes,
    }

    if $deployment {
      class { 'profiles::uitpas::api::deployment':
        database_password => $database_password,
        database_host     => $database_host,
        portbase          => $portbase,
        service_watchdog  => $service_watchdog
      }

      class { 'profiles::uitpas::api::cron':
        portbase => $portbase,
        require  => Class['profiles::uitpas::api::deployment'],
      }

      Class['profiles::glassfish'] -> Class['profiles::uitpas::api::deployment']
      Package['liquibase'] -> Class['profiles::uitpas::api::deployment']
      Package['mysql-connector-j'] -> Class['profiles::uitpas::api::deployment']
      File['Domain uitpas mysql-connector-j'] -> Class['profiles::uitpas::api::deployment']
      Profiles::Mysql::App_user["${database_user}@${database_name}"] -> Class['profiles::uitpas::api::deployment']
      Class['profiles::uitpas::api::deployment'] ~> Service['uitpas']
    }
  }

  set { 'server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping':
    ensure  => 'present',
    value   => 'X-Forwarded-Proto',
    require => Profiles::Glassfish::Domain['uitpas'],
    notify  => Service['uitpas'],
    *       => $default_attributes,
  }

  set { 'server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size':
    ensure  => 'present',
    value   => '32',
    require => Profiles::Glassfish::Domain['uitpas'],
    notify  => Service['uitpas'],
    *       => $default_attributes,
  }

  jvmoption { 'Clear domain uitpas default truststore':
    ensure  => 'absent',
    option  => '-Djavax.net.ssl.trustStore=\$\{com.sun.aas.instanceRoot\}/config/cacerts.jks',
    require => Profiles::Glassfish::Domain['uitpas'],
    notify  => Service['uitpas'],
    *       => $default_attributes,
  }

  jvmoption { 'Domain uitpas truststore':
    ensure  => 'present',
    option  => '-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts',
    require => Profiles::Glassfish::Domain['uitpas'],
    notify  => Service['uitpas'],
    *       => $default_attributes,
  }

  jvmoption { 'Domain uitpas timezone':
    ensure  => 'present',
    option  => '-Duser.timezone=CET',
    require => Profiles::Glassfish::Domain['uitpas'],
    notify  => Service['uitpas'],
    *       => $default_attributes,
  }

  $settings.each |$name, $value| {
    systemproperty { $name:
      ensure  => 'present',
      value   => $value,
      require => Profiles::Glassfish::Domain['uitpas'],
      notify  => Service['uitpas'],
      *       => $default_attributes,
    }
  }

  profiles::glassfish::domain::service_alias { 'uitpas':
    require => Profiles::Glassfish::Domain['uitpas'],
  }

  service { 'uitpas':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
      'running' => true,
      'stopped' => false
    },
    require   => Profiles::Glassfish::Domain::Service_alias['uitpas'],
  }

  file { 'Domain uitpas mysql-connector-j':
    ensure  => 'file',
    path    => '/opt/payara/glassfish/lib/mysql-connector-j.jar',
    source  => '/usr/share/java/mysql-connector-j.jar',
    require => Package['mysql-connector-j'],
    before  => Profiles::Glassfish::Domain['uitpas'],
  }

  # include ::profiles::uitpas::api::monitoring
  # include ::profiles::uitpas::api::metrics
  # include ::profiles::uitpas::api::backup
  # include ::profiles::uitpas::api::logging
}
