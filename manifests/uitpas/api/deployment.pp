class profiles::uitpas::api::deployment (
  String           $database_password,
  String           $database_host         = '127.0.0.1',
  String           $version               = 'latest',
  String           $repository            = 'uitpas-api',
  Integer          $portbase              = 4800,
  Boolean          $service_watchdog      = false,
  String           $health_url            = 'https://localhost:4881/uitid/rest/uitpas/health',
  String           $cardsystem_health_url = 'https://localhost:4881/uitid/rest/cardsystem/login',
  Optional[String] $puppetdb_url          = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits profiles {
  $database_name = 'uitpas_api'
  $database_user = 'uitpas_api'

  realize Apt::Source[$repository]
  realize User['glassfish']

  package { 'uitpas-api':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [App['uitpas-api'], Profiles::Deployment::Versions[$title]],
  }

  package { 'uitpas-db-mgmt':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => Profiles::Deployment::Versions[$title],
  }

  exec { 'uitpas_database_management':
    command     => "liquibase --driver=com.mysql.cj.jdbc.Driver --classpath=/opt/uitpas-db-mgmt/uitpas-db-mgmt.jar:/usr/share/java/mysql-connector-j.jar --changeLogFile=migrations.xml --url='jdbc:mysql://${database_host}:3306/${database_name}?useSSL=false' --username=${database_user} --password=${database_password} update",
    path        => ['/opt/liquibase', '/usr/local/bin', '/usr/bin', '/bin'],
    refreshonly => true,
    logoutput   => true,
    subscribe   => Package['uitpas-db-mgmt'],
    before      => App['uitpas-api'],
  }

  app { 'uitpas-api':
    ensure        => 'present',
    portbase      => String($portbase),
    user          => 'glassfish',
    passwordfile  => '/home/glassfish/asadmin.pass',
    contextroot   => 'uitid',
    precompilejsp => false,
    source        => '/opt/uitpas-api/uitpas-api.war',
    require       => User['glassfish'],
  }

  profiles::systemd::service_watchdog { 'uitpas':
    ensure                 => $service_watchdog ? {
      true  => 'present',
      false => 'absent'
    },
    check_interval_seconds => 20,
    timeout_seconds        => 120,
    healthcheck            => template('profiles/uitpas/api/deployment/service_healthcheck.erb'),
  }
  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url,
  }
}
