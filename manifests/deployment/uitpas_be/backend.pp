class profiles::deployment::uitpas_be::backend (
  String           $config_source,
  String           $version        = 'latest',
  Optional[String] $puppetdb_url   = undef
) inherits ::profiles {

  $basedir = '/var/www/uitpas-website-api'

  realize Apt::Source['uitpas-website-api']

  # TODO: package notify Apache::Service ?
  # TODO: config file notify Apache::Service ?

  package { 'uitpas-website-api':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['uitpas-website-api']
  }

  file { 'uitpasbe-backend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    source  => $config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['uitpas-website-api']
  }

  exec { 'uitpasbe-backend_cache_clear':
    command     => 'php bin/console cache:clear',
    cwd         => $basedir,
    user        => 'www-data',
    group       => 'www-data',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    subscribe   => Package['uitpas-website-api'],
    refreshonly => true
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
