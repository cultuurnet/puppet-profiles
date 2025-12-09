class profiles::uitpas::balie_frontend::deployment (
  String           $config_source,
  String           $version       = 'latest',
  String           $repository    = 'uitpas-balie-frontend',
  Optional[String] $puppetdb_url  = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitpas-balie-api/web/app_v1'
  $secrets = lookup('vault:uitpas/balie-frontend')

  realize Group['www-data']
  realize User['www-data']

  realize Apt::Source['publiq-tools']
  realize Package['rubygem-angular-config']

  realize Apt::Source[$repository]

  package { 'uitpas-balie-frontend':
    ensure  => $version,
    require => [Apt::Source[$repository], Group['www-data'], User['www-data']],
    notify  => Profiles::Deployment::Versions[$title]
  }

  file { 'uitpas-balie-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/config.json",
    content  => template($config_source),
    owner   => 'www-data',
    group   => 'www-data',
    require => [Package['uitpas-balie-frontend'], Group['www-data'], User['www-data']]
  }

  file { 'uitpas-balie-frontend-deploy-config':
    ensure  => 'file',
    path    => '/usr/local/bin/uitpas-balie-frontend-deploy-config',
    source  => 'puppet:///modules/profiles/uitpas/balie_frontend/angular-deploy-config.rb',
    mode    => '0755',
    require => Package['rubygem-angular-config']
  }

  exec { 'uitpas-balie-frontend-deploy-config':
    command     => "uitpas-balie-frontend-deploy-config ${basedir}",
    path        => ['/usr/local/bin', '/usr/bin', '/bin'],
    refreshonly => true,
    subscribe   => [Package['uitpas-balie-frontend'], File['uitpas-balie-frontend-config'], File['uitpas-balie-frontend-deploy-config']]
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
