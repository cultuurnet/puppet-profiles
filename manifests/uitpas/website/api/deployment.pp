class profiles::uitpas::website::api::deployment (
  String                     $config_source,
  String                     $version           = 'latest',
  String                     $repository        = 'uitpas-website-api',
  Optional[String]           $puppetdb_url      = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitpas-website-api'
  $secrets = lookup('vault:uitpas/website/api')

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uitpas-website-api':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source[$repository]
  }

  file { 'uitpas-website-api-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    content  => template($config_source),
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['uitpas-website-api']
  }

  exec { 'uitpasbe-api_cache_clear':
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
