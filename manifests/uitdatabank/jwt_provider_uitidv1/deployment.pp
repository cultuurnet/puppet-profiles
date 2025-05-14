class profiles::uitdatabank::jwt_provider_uitidv1::deployment (
  String           $config_source,
  String           $private_key_source,
  String           $public_key_source,
  String           $version            = 'latest',
  String           $repository         = 'uitdatabank-jwt-provider-uitidv1',
  Optional[String] $puppetdb_url       = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir                 = '/var/www/jwt-provider-uitidv1'
  $secrets                 = lookup('vault:uitdatabank/udb3-jwtprovider')
  $file_default_attributes = {
                               owner   => 'www-data',
                               group   => 'www-data',
                               require => [Group['www-data'], User['www-data'], Package['uitdatabank-jwt-provider-uitidv1']],
                               notify  => Service['uitdatabank-jwt-provider-uitidv1']
                             }

  realize Group['www-data']
  realize User['www-data']
  realize Apt::Source[$repository]

  package { 'uitdatabank-jwt-provider-uitidv1':
    ensure  => $version,
    notify  => [Service['uitdatabank-jwt-provider-uitidv1'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uitdatabank-jwt-provider-uitidv1-config':
    ensure  => 'file',
    path    => "${basedir}/config.yml",
    content => template($config_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-jwt-provider-uitidv1-private-key':
    ensure  => 'file',
    path    => "${basedir}/private.pem",
    content => template($private_key_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-jwt-provider-uitidv1-public-key':
    ensure  => 'file',
    path    => "${basedir}/public.pem",
    content => template($public_key_source),
    *       => $file_default_attributes
  }

  profiles::php::fpm_service_alias { 'uitdatabank-jwt-provider-uitidv1': }

  service { 'uitdatabank-jwt-provider-uitidv1':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload uitdatabank-jwt-provider-uitidv1',
    require    => Profiles::Php::Fpm_service_alias['uitdatabank-jwt-provider-uitidv1']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
