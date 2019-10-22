class profiles::deployment::uitpas_be::backend (
  String           $config_source,
  String           $package_version = 'latest',
  Optional[String] $puppetdb_url    = undef
) {

  $basedir = '/var/www/uitpasbe-backend'

  contain profiles
  contain profiles::deployment::uitpas_be

  realize Apt::Source['publiq-uitpasbe']
  realize Profiles::Apt::Update['publiq-uitpasbe']

  # TODO: package notify Apache::Service ?
  # TODO: config file notify Apache::Service ?

  package { 'uitpasbe-backend':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uitpasbe']
  }

  file { 'uitpasbe-backend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    source  => $config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['uitpasbe-backend']
  }

  exec { 'uitpasbe-backend_cache_clear':
    command     => 'php bin/console cache:clear',
    cwd         => $basedir,
    user        => 'www-data',
    group       => 'www-data',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    subscribe   => Package['uitpasbe-backend'],
    refreshonly => true
  }

  profiles::deployment::versions { $title:
    project      => 'uitpasbe',
    packages     => 'uitpasbe-backend',
    puppetdb_url => $puppetdb_url
  }
}
