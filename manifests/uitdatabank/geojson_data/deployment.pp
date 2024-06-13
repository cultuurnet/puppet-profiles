class profiles::uitdatabank::geojson_data::deployment (
  String           $version        = 'latest',
  String           $repository     = 'uitdatabank-geojson-data',
  Optional[String] $puppetdb_url   = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  realize Apt::Source[$repository]

  package { 'uitdatabank-geojson-data':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source[$repository]
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
