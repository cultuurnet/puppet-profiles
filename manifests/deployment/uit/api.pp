class profiles::deployment::uit::api (
  String           $config_source,
  String           $version                 = 'latest',
  Boolean          $service_manage          = true,
  String           $service_ensure          = 'running',
  Boolean          $service_enable          = true,
  Optional[String] $service_defaults_source = undef,
  Optional[String] $puppetdb_url            = undef
) {

  $basedir = '/var/www/uit-api'

  contain ::profiles

  include ::profiles::apt::updates
  include ::profiles::deployment::uit

  realize Profiles::Apt::Update['yarn']
  realize Profiles::Apt::Update['publiq-uit']

  realize Package['yarn']

  package { 'uit-api':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uit']
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
    project      => 'uit',
    packages     => 'uit-api',
    puppetdb_url => $puppetdb_url
  }
}
