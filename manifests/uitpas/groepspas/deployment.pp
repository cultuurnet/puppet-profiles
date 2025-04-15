class profiles::uitpas::groepspas::deployment (
  String           $config_source,
  String           $version       = 'latest',
  String           $repository    = 'uitpas-groepspas',
  Optional[String] $puppetdb_url  = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitpas-groepspas'

  realize Group['www-data']
  realize User['www-data']

  realize Apt::Source['publiq-tools']
  realize Package['rubygem-angular-config']

  realize Apt::Source[$repository]

  package { 'uitpas-groepspas':
    ensure  => $version,
    require => [Apt::Source[$repository], Group['www-data'], User['www-data']],
    notify  => Profiles::Deployment::Versions[$title]
  }

  file { 'uitpas-groepspas-config':
    ensure  => 'file',
    path    => "${basedir}/config.json",
    source  => $config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => [Package['uitpas-groepspas'], Group['www-data'], User['www-data']]
  }

  file { 'uitpas-groepspas-deploy-config':
    ensure  => 'file',
    path    => '/usr/local/bin/uitpas-groepspas-deploy-config',
    source  => 'puppet:///modules/profiles/uitpas/groepspas/angular-deploy-config.rb',
    mode    => '0755',
    require => Package['rubygem-angular-config']
  }

  exec { 'uitpas-groepspas-deploy-config':
    command     => "uitpas-groepspas-deploy-config ${basedir}",
    path        => ['/usr/local/bin', '/usr/bin', '/bin'],
    refreshonly => true,
    subscribe   => [Package['uitpas-groepspas'], File['uitpas-groepspas-config'], File['uitpas-groepspas-deploy-config']]
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
