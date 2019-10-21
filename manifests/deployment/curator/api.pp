class profiles::deployment::curator::api (
  String           $config_source,
  String           $package_version = 'latest',
  Optional[String] $puppetdb_url    = undef
) {

  $basedir = '/var/www/curator-api'

  contain profiles
  contain profiles::deployment::curator

  realize Apt::Source['publiq-curator']
  realize Profiles::Apt::Update['publiq-curator']

  # TODO: package notify Apache::Service ?
  # TODO: config file notify Apache::Service ?

  package { 'curator-api':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-curator']
  }

  file { 'curator-api-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    source  => $config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['curator-api']
  }

  exec { 'curator-api_db_schema_update':
    command     => 'php bin/console doctrine:migrations:migrate --no-interaction',
    cwd         => $basedir,
    user        => 'www-data',
    group       => 'www-data',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    subscribe   => Package['curator-api'],
    refreshonly => true
  }

  exec { 'curator-api_cache_clear':
    command     => 'php bin/console cache:clear',
    cwd         => $basedir,
    user        => 'www-data',
    group       => 'www-data',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    subscribe   => Package['curator-api'],
    require     => Exec['curator-api_db_schema_update'],
    refreshonly => true
  }

  profiles::deployment::versions { $title:
    project      => 'curator',
    packages     => 'curator-api',
    puppetdb_url => $puppetdb_url
  }
}
