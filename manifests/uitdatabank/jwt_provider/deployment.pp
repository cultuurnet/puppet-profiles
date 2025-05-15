class profiles::uitdatabank::jwt_provider::deployment (
  String           $config_source,
  String           $version       = 'latest',
  String           $repository    = 'uitdatabank-jwt-provider',
  Optional[String] $puppetdb_url  = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/jwt-provider'
  $secrets = lookup('vault:uitdatabank/udb3-jwtprovider')

  realize Group['www-data']
  realize User['www-data']
  realize Apt::Source[$repository]

  package { 'uitdatabank-jwt-provider':
    ensure  => $version,
    notify  => [Service['uitdatabank-jwt-provider'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uitdatabank-jwt-provider-config':
    ensure  => 'file',
    path    => "${basedir}/config.yml",
    content => template($config_source),
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data'], Package['uitdatabank-jwt-provider']],
    notify  => Service['uitdatabank-jwt-provider']
  }

  profiles::php::fpm_service_alias { 'uitdatabank-jwt-provider': }

  service { 'uitdatabank-jwt-provider':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload uitdatabank-jwt-provider',
    require    => Profiles::Php::Fpm_service_alias['uitdatabank-jwt-provider']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
