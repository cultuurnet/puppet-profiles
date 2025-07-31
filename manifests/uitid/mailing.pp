class profiles::uitid::mailing (
  String $servername,
  Variant[String,Array[String]] $serveraliases = [],
  String $database_password,
  String $database_host                        = '127.0.0.1',
  String $config_source,
  String $version                              = 'latest',
  String $repository                           = 'uitid-mailing',
  Boolean $deployment                          = true,
  Optional[String] $initial_heap_size          = undef,
  Optional[String] $maximum_heap_size          = undef,
  Boolean $jmx                                 = true,
  Integer $portbase                            = 4800,
  Enum['running', 'stopped'] $service_status   = 'running',
  Hash $settings                               = {}

) inherits profiles {
  $database_name              = 'uitid_mailing'
  $database_user              = 'uitid_mailing'
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
    destination   => "http://127.0.0.1:${glassfish_domain_http_port}/",
    aliases       => $serveraliases,
    preserve_host => true,
  }

  $database_host_remote = true

  class { 'profiles::mysql::remote_server':
    host => $database_host,
  }

  if $facts['mysqld_version'] {
    $database_host_available = true
  } else {
    $database_host_available = false
  }
  realize Group['glassfish']
  realize User['glassfish']

  realize Apt::Source['publiq-tools']
  realize Package['mysql-connector-j']

  profiles::glassfish::domain { 'uitid-mailing':
    portbase          => $portbase,
    initial_heap_size => $initial_heap_size,
    maximum_heap_size => $maximum_heap_size,
    jmx               => $jmx,
    service_status    => $service_status,
    require           => Class['profiles::glassfish'],
    notify            => Service['uitid-mailing'],
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

    jdbcconnectionpool { 'mysql_uitid_mailing_j2eePool':
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
      require      => [Profiles::Glassfish::Domain['uitid-mailing'], Profiles::Mysql::App_user["${database_user}@${database_name}"]],
      *            => $default_attributes,
    }

    jdbcresource { 'jdbc/mailing':
      ensure         => 'present',
      connectionpool => 'mysql_uitid_mailing_j2eePool',
      require        => Jdbcconnectionpool['mysql_uitid_mailing_j2eePool'],
      *              => $default_attributes,
    }

    if $deployment {
      class { 'profiles::uitid::mailing::deployment':
        portbase          => $portbase,
        config_source => $config_source,
        cron_enabled    => $cron_enabled,
      }

      Class['profiles::glassfish'] -> Class['profiles::uitid::mailing::deployment']
      Package['mysql-connector-j'] -> Class['profiles::uitid::mailing::deployment']
      File['Domain uitid-mailing mysql-connector-j'] -> Class['profiles::uitid::mailing::deployment']
      Profiles::Mysql::App_user["${database_user}@${database_name}"] -> Class['profiles::uitid::mailing::deployment']
      Class['profiles::uitid::mailing::deployment'] ~> Service['uitid-mailing']
    }
  }
  set { 'server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping':
    ensure  => 'present',
    value   => 'X-Forwarded-Proto',
    require => Profiles::Glassfish::Domain['uitid-mailing'],
    notify  => Service['uitid-mailing'],
    *       => $default_attributes,
  }


  set { 'server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size':
    ensure  => 'present',
    value   => '32',
    require => Profiles::Glassfish::Domain['uitid-mailing'],
    notify  => Service['uitid-mailing'],
    *       => $default_attributes,
  }

  jvmoption { 'Clear domain uitid-mailing default truststore':
    ensure  => 'absent',
    option  => '-Djavax.net.ssl.trustStore=\$\{com.sun.aas.instanceRoot\}/config/cacerts.jks',
    require => Profiles::Glassfish::Domain['uitid-mailing'],
    notify  => Service['uitid-mailing'],
    *       => $default_attributes,
  }

  jvmoption { 'Domain uitid-mailing truststore':
    ensure  => 'present',
    option  => '-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts',
    require => Profiles::Glassfish::Domain['uitid-mailing'],
    notify  => Service['uitid-mailing'],
    *       => $default_attributes,
  }

  jvmoption { 'Domain uitid-mailing timezone':
    ensure  => 'present',
    option  => '-Duser.timezone=CET',
    require => Profiles::Glassfish::Domain['uitid-mailing'],
    notify  => Service['uitid-mailing'],
    *       => $default_attributes,
  }

  $settings.each |$name, $value| {
    systemproperty { $name:
      ensure  => 'present',
      value   => $value,
      require => Profiles::Glassfish::Domain['uitid-mailing'],
      notify  => Service['uitid-mailing'],
      *       => $default_attributes,
    }
  }
  profiles::glassfish::domain::service_alias { 'uitid-mailing':
    require => Profiles::Glassfish::Domain['uitid-mailing'],
  }

  service { 'uitid-mailing':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
      'running' => true,
      'stopped' => false
    },
    require   => Profiles::Glassfish::Domain::Service_alias['uitid-mailing'],
  }

  file { 'Domain uitid-mailing mysql-connector-j':
    ensure  => 'file',
    path    => '/opt/payara/glassfish/lib/mysql-connector-j.jar',
    source  => '/usr/share/java/mysql-connector-j.jar',
    require => Package['mysql-connector-j'],
    before  => Profiles::Glassfish::Domain['uitid-mailing'],
  }
}
