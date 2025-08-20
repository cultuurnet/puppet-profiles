class profiles::widgetbeheer::frontend::deployment (
  String           $config_source,
  String           $version       = 'latest',
  String           $repository    = 'widgetbeheer-frontend',
  Optional[String] $puppetdb_url  = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/widgetbeheer-frontend'
  $secrets = lookup('vault:widgetbeheer/frontend')

  realize Group['www-data']
  realize User['www-data']

  realize Apt::Source[$repository]

  package { 'widgetbeheer-frontend':
    ensure  => $version,
    require => [Apt::Source[$repository], Group['www-data'], User['www-data']],
    notify  => Profiles::Deployment::Versions[$title]
  }

  file { 'widgetbeheer-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/assets/config.json",
    content => template($config_source),
    owner   => 'www-data',
    group   => 'www-data',
    require => [Package['widgetbeheer-frontend'], Group['www-data'], User['www-data']]
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
