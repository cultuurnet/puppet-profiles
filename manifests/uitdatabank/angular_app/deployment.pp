class profiles::uitdatabank::angular_app::deployment (
  String           $config_source,
  String           $version       = 'latest',
  String           $repository    = 'uitdatabank-angular-app',
  Optional[String] $puppetdb_url  = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/udb3-angular-app'

  realize Group['www-data']
  realize User['www-data']

  realize Apt::Source['publiq-tools']
  realize Package['rubygem-angular-config']

  realize Apt::Source[$repository]

  package { 'uitdatabank-angular-app':
    ensure  => $version,
    require => [Apt::Source[$repository], Group['www-data'], User['www-data']],
    notify  => Profiles::Deployment::Versions[$title]
  }

  file { 'uitdatabank-angular-app-config':
    ensure  => 'file',
    path    => "${basedir}/config.json",
    source  => $config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => [Package['uitdatabank-angular-app'], Group['www-data'], User['www-data']]
  }

  file { 'uitdatabank-angular-app-deploy-config':
    ensure  => 'file',
    path    => '/usr/local/bin/uitdatabank-angular-app-deploy-config',
    source  => 'puppet:///modules/profiles/uitdatabank/angular_app/angular-deploy-config.rb',
    mode    => '0755',
    require => Package['rubygem-angular-config']
  }

  exec { 'uitdatabank-angular-app-deploy-config':
    command     => "uitdatabank-angular-app-deploy-config ${basedir}",
    path        => ['/usr/local/bin', '/usr/bin', '/bin'],
    refreshonly => true,
    subscribe   => [Package['uitdatabank-angular-app'], File['uitdatabank-angular-app-config'], File['uitdatabank-angular-app-deploy-config']]
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
