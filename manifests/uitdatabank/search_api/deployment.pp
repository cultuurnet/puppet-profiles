class profiles::uitdatabank::search_api::deployment (
  String           $version        = 'latest',
  String           $repository     = 'uitdatabank-search-api',
  Boolean          $data_migration = false,
  Optional[String] $puppetdb_url   = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  realize Apt::Source[$repository]

  package { 'uitdatabank-search-api':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source[$repository]
  }

  if $data_migration {
    Package['uitdatabank-search-api'] ~> Class['profiles::uitdatabank::search_api::data_migration']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
