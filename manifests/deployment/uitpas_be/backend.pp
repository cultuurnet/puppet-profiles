class profiles::deployment::uitpas_be::backend (
  String           $config_source,
  String           $package_version = 'latest',
  Optional[String] $puppetdb_url    = undef
) {

  $basedir = '/var/www/uitpas.be-backend'

  contain profiles
  contain profiles::deployment::uitpas_be

  realize Apt::Source['publiq-uitpas.be']
  realize Profiles::Apt::Update['publiq-uitpas.be']

  # TODO: package notify Apache::Service ?
  # TODO: config file notify Apache::Service ?

  package { 'uitpas.be-backend':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uitpas.be']
  }

  file { 'uitpas.be-backend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    source  => $config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['uitpas.be-backend']
  }

  exec { 'uitpas.be-backend_cache_clear':
    command     => 'php bin/console cache:clear',
    cwd         => $basedir,
    user        => 'www-data',
    group       => 'www-data',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    subscribe   => Package['uitpas.be-backend'],
    refreshonly => true
  }

  profiles::deployment::versions { $title:
    project      => 'uitpas.be',
    packages     => 'uitpas.be-backend',
    puppetdb_url => $puppetdb_url
  }
}
