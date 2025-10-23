class profiles::uitid::api (
  String                         $database_password,
  String                         $database_host        = '127.0.0.1',
  Boolean                        $deployment           = true,
  Optional[String]               $initial_heap_size    = undef,
  Optional[String]               $maximum_heap_size    = undef,
  Boolean                        $jmx                  = true,
  Boolean                        $newrelic             = false,
  Optional[String]               $newrelic_license_key = lookup('data::newrelic::license_key', Optional[String], 'first', undef),
  Integer                        $portbase             = 4800,
  Enum['running', 'stopped']     $service_status       = 'running',
  Hash                           $settings             = {}
) inherits profiles {

  $database_name              = 'uitid_api'
  $database_user              = 'uitid_api'
  $glassfish_domain_http_port = $portbase + 80
  $default_attributes         = {
                                  user         => 'glassfish',
                                  passwordfile => '/home/glassfish/asadmin.pass',
                                  portbase     => String($portbase)
                                }

  include profiles::java
  include profiles::glassfish

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
  realize Package['mysql-connector-j']

  profiles::glassfish::domain { 'uitid':
    portbase             => $portbase,
    initial_heap_size    => $initial_heap_size,
    maximum_heap_size    => $maximum_heap_size,
    jmx                  => $jmx,
    newrelic             => $newrelic,
    newrelic_app_name    => "uitid-api-${environment}",
    newrelic_license_key => $newrelic_license_key,
    service_status       => $service_status,
    require              => Class['profiles::glassfish'],
    notify               => Service['uitid']
  }

  if $database_host_available {
    mysql_database { $database_name:
      charset => 'utf8mb4',
      collate => 'utf8mb4_unicode_ci'
    }

    profiles::mysql::app_user { "${database_user}@${database_name}":
      password => $database_password,
      remote   => $database_host_remote,
      require  => Mysql_database[$database_name]
    }

    profiles::mysql::app_user { "etl@${database_name}":
      password => lookup('data::mysql::etl::password', Optional[String], 'first', undef),
      readonly => true,
      remote   => $database_host_remote,
      require  => Mysql_database[$database_name]
    }

    jdbcconnectionpool { 'mysql_uitid_api_j2eePool':
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
      require      => [Profiles::Glassfish::Domain['uitid'], Profiles::Mysql::App_user["${database_user}@${database_name}"]],
      notify       => Service['uitid'],
      *            => $default_attributes
    }

    jdbcresource { 'jdbc/cultuurnet_uitid':
      ensure         => 'present',
      connectionpool => 'mysql_uitid_api_j2eePool',
      require        => Jdbcconnectionpool['mysql_uitid_api_j2eePool'],
      notify         => Service['uitid'],
      *              => $default_attributes
    }

    if $deployment {
      class { 'profiles::uitid::api::deployment':
        portbase          => $portbase
      }

      class { 'profiles::uitid::api::cron':
        portbase => $portbase,
        require  => Class['profiles::uitid::api::deployment']
      }

      Class['profiles::glassfish'] -> Class['profiles::uitid::api::deployment']
      Package['mysql-connector-j'] -> Class['profiles::uitid::api::deployment']
      File['Domain uitid mysql-connector-j'] -> Class['profiles::uitid::api::deployment']
      Profiles::Mysql::App_user["${database_user}@${database_name}"] -> Class['profiles::uitid::api::deployment']
      Class['profiles::uitid::api::deployment'] ~> Service['uitid']
    }
  }

  set { 'server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping':
    ensure  => 'present',
    value   => 'X-Forwarded-Proto',
    require => Profiles::Glassfish::Domain['uitid'],
    notify  => Service['uitid'],
    *       => $default_attributes
  }

  set { 'server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size':
    ensure  => 'present',
    value   => '32',
    require => Profiles::Glassfish::Domain['uitid'],
    notify  => Service['uitid'],
    *       => $default_attributes
  }

  jvmoption { 'Clear domain uitid default truststore':
    ensure  => 'absent',
    option  => '-Djavax.net.ssl.trustStore=\$\{com.sun.aas.instanceRoot\}/config/cacerts.jks',
    require => Profiles::Glassfish::Domain['uitid'],
    notify  => Service['uitid'],
    *       => $default_attributes
  }

  jvmoption { 'Domain uitid truststore':
    ensure  => 'present',
    option  => '-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts',
    require => Profiles::Glassfish::Domain['uitid'],
    notify  => Service['uitid'],
    *       => $default_attributes
  }

  jvmoption { 'Domain uitid timezone':
    ensure  => 'present',
    option  => '-Duser.timezone=CET',
    require => Profiles::Glassfish::Domain['uitid'],
    notify  => Service['uitid'],
    *       => $default_attributes
  }

  $settings.each |$name, $value| {
    systemproperty { $name:
      ensure  => 'present',
      value   => $value,
      require => Profiles::Glassfish::Domain['uitid'],
      notify  => Service['uitid'],
      *       => $default_attributes
    }
  }

  profiles::glassfish::domain::service_alias { 'uitid':
    require => Profiles::Glassfish::Domain['uitid']
  }

  service { 'uitid':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    require   => Profiles::Glassfish::Domain::Service_alias['uitid']
  }

  file { 'Domain uitid mysql-connector-j':
    ensure  => 'file',
    path    => '/opt/payara/glassfish/lib/mysql-connector-j.jar',
    source  => '/usr/share/java/mysql-connector-j.jar',
    require => Package['mysql-connector-j'],
    before  => Profiles::Glassfish::Domain['uitid']
  }

  # include ::profiles::uitid::api::monitoring
  # include ::profiles::uitid::api::metrics
  # include ::profiles::uitid::api::backup
  # include ::profiles::uitid::api::logging
}
