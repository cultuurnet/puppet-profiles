class profiles::uit::api::deployment (
  String                     $config_source,
  Integer                    $maximum_heap_size    = 512,
  String                     $version              = 'latest',
  String                     $repository           = 'uit-api',
  Enum['running', 'stopped'] $service_status       = 'running',
  Integer                    $service_port         = 4000,
  Optional[String]           $newrelic_license_key = undef,
  Optional[String]           $newrelic_app_name    = undef,
  Optional[String]           $puppetdb_url         = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uit-api'
  $secrets = lookup('vault:uit/api')

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uit-api':
    ensure  => $version,
    notify  => [Service['uit-api'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uit-api-config-graphql':
    ensure  => 'file',
    path    => "${basedir}/packages/graphql/.env",
    owner   => 'www-data',
    group   => 'www-data',
    content  => template($config_source),
    require => [Package['uit-api'], Group['www-data'], User['www-data']],
    # notify  => [Exec['uit-api-graphql-schema-update'], Service['uit-api']]
    notify  => Service['uit-api']
  }

  file { 'uit-api-config-db':
    ensure  => 'file',
    path    => "${basedir}/packages/db/.env",
    owner   => 'www-data',
    group   => 'www-data',
    content  => template($config_source),
    require => [Package['uit-api'], Group['www-data'], User['www-data']],
    notify  => [Exec['uit-api-db-schema-update'], Service['uit-api']]
  }

  file { 'uit-api-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uit-api',
    owner   => 'root',
    group   => 'root',
    content => template('profiles/uit/api/deployment/uit-api.erb'),
    notify  => Service['uit-api']
  }

  # 2024-05-16: temp disable, requested by Simon
  # because of Graphql upgrade
  #
  # exec { 'uit-api-graphql-schema-update':
  #   command     => 'yarn graphql typeorm migration:run',
  #   cwd         => $basedir,
  #   user        => 'www-data',
  #   group       => 'www-data',
  #   path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
  #   refreshonly => true,
  #   require     => [Group['www-data'], User['www-data']],
  #   subscribe   => [Package['uit-api'], File['uit-api-config-graphql']],
  #   notify      => Service['uit-api']
  # }

  exec { 'uit-api-db-schema-update':
    command     => 'yarn db typeorm migration:run',
    cwd         => $basedir,
    user        => 'www-data',
    group       => 'www-data',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    refreshonly => true,
    require     => [Group['www-data'], User['www-data']],
    subscribe   => [Package['uit-api'], File['uit-api-config-db']],
    notify      => Service['uit-api']
  }

  service { 'uit-api':
    ensure    => $service_status,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    hasstatus => true
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
