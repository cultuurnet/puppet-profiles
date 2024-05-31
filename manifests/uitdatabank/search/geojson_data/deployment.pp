class profiles::uitdatabank::search::geojson_data::deployment (
  String           $version        = 'latest',
  String           $repository     = 'uitdatabank-geojson-data',
  Boolean          $data_migration = false,
  Optional[String] $puppetdb_url   = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  realize Apt::Source[$repository]

  package { 'uitdatabank-geojson-data':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source[$repository]
  }

  if $data_migration {
    Package['uitdatabank-geojson-data'] ~> Class['profiles::uitdatabank::search::data_migration']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
