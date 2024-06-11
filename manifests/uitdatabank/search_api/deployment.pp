class profiles::uitdatabank::search_api::deployment (
  String           $version        = 'latest',
  String           $repository     = 'uitdatabank-search-api',
  Boolean          $data_migration = false,
  String           $basedir        = '/var/www/udb3-search-service',
  Optional[String] $puppetdb_url   = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  realize Apt::Source[$repository]

  package { 'uitdatabank-search-api':
    ensure  => $version,
    notify  => [Service['uitdatabank-search-api'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  if $data_migration {
    Package['uitdatabank-search-api'] ~> Class['profiles::uitdatabank::search_api::data_migration']
  }

  profiles::php::fpm_service_alias { 'uitdatabank-search-api': }

  service { 'uitdatabank-search-api':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload uitdatabank-search-api',
    require    => Profiles::Php::Fpm_service_alias['uitdatabank-search-api'],
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
