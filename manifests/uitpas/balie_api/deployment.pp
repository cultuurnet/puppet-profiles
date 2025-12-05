class profiles::uitpas::balie_api::deployment (
  String           $config_source,
  String           $version       = 'latest',
  String           $repository    = 'uitpas-balie-api',
  Optional[String] $puppetdb_url  = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitpas-balie-api'
  $secrets = lookup('vault:uitpas/balie-api')

  realize Group['www-data']
  realize User['www-data']
  realize Apt::Source[$repository]

  package { 'uitpas-balie-api':
    ensure  => $version,
    notify  => [Service['uitpas-balie-api'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uitpas-balie-api-config':
    ensure  => 'file',
    path    => "${basedir}/config.yml",
    content  => template($config_source),
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data'], Package['uitpas-balie-api']],
    notify  => Service['uitpas-balie-api']
  }

  profiles::php::fpm_service_alias { 'uitpas-balie-api': }

  service { 'uitpas-balie-api':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload uitpas-balie-api',
    require    => Profiles::Php::Fpm_service_alias['uitpas-balie-api']
  }

  class { 'profiles::uitpas::balie_api::logrotate':
    basedir => $basedir
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
