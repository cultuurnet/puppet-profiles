class profiles::uitid::frontend_auth0::deployment (
  String                     $config_source,
  String                     $version       = 'latest',
  String                     $repository    = 'uitid-frontend-auth0',
  Optional[String]           $puppetdb_url  = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitid-frontend-auth0'

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uitid-frontend-auth0':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => Profiles::Deployment::Versions[$title]
  }


  #file { 'uitid-frontend-auth0-config':
  #  ensure  => 'file',
  #  path    => "${basedir}/.env",
  #  owner   => 'www-data',
  #  group   => 'www-data',
  #  source  => $config_source,
  #  require => [Package['uitid-frontend-auth0'], Group['www-data'], User['www-data']]
  #}

  #exec for upload to S3

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
