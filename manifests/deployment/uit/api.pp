class profiles::deployment::uit::api (
  String           $config_source,
  String           $version                 = 'latest',
  Boolean          $service_manage          = true,
  String           $service_ensure          = 'running',
  Boolean          $service_enable          = true,
  Optional[String] $service_defaults_source = undef,
  Optional[String] $puppetdb_url            = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uit-api'

  realize Apt::Source['publiq-tools']
  realize Apt::Source['uit-api']

  realize Package['yarn']

  package { 'uit-api':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['uit-api']
  }

  file { 'uit-api-config-graphql':
    ensure  => 'file',
    path    => "${basedir}/packages/graphql/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-api']
  }

  file { 'uit-api-config-db':
    ensure  => 'file',
    path    => "${basedir}/packages/db/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-api']
  }

  file { 'uit-api-log':
    ensure => 'directory',
    path   => '/var/log/uit-api',
    owner  => 'www-data',
    group  => 'www-data'
  }

  exec { 'uit-api_graphql_schema_update':
    command     => 'yarn graphql typeorm migration:run',
    cwd         => $basedir,
    user        => 'www-data',
    group       => 'www-data',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    refreshonly => true,
    subscribe   => [ Package['uit-api'], File['uit-api-config-graphql']],
    require     => Package['yarn']
  }

  exec { 'uit-api_db_schema_update':
    command     => 'yarn db typeorm migration:run',
    cwd         => $basedir,
    user        => 'www-data',
    group       => 'www-data',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    refreshonly => true,
    subscribe   => [ Package['uit-api'], File['uit-api-config-db']],
    require     => Package['yarn']
  }

  if $service_manage {
    if $service_defaults_source {
      file { 'uit-api-service-defaults':
        ensure => 'file',
        path   => '/etc/default/uit-api',
        owner  => 'root',
        group  => 'root',
        source => $service_defaults_source,
        notify => Service['uit-api']
      }
    }

    service { 'uit-api':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => [ Package['uit-api'], File['uit-api-log']],
      subscribe => File['uit-api-config-graphql'],
      hasstatus => true
    }
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
