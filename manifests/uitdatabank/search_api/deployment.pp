class profiles::uitdatabank::search_api::deployment (
  String           $config_source,
  String           $features_source,
  String           $facilities_source,
  String           $themes_source,
  String           $types_source,
  String           $pubkey_auth0_source,
  String           $version                = 'latest',
  String           $repository             = 'uitdatabank-search-api',
  String           $basedir                = '/var/www/udb3-search-service',
  String           $region_mapping_source  = 'puppet:///modules/profiles/uitdatabank/search_api/mapping_region.json',
  Optional[String] $default_queries_source = undef,
  Optional[String] $puppetdb_url           = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $file_default_attributes = {
                               owner   => 'www-data',
                               group   => 'www-data',
                               require => [Group['www-data'], User['www-data'], Package['uitdatabank-search-api']],
                               notify  => [Service['uitdatabank-search-api'], Class['profiles::uitdatabank::search_api::listeners']]
                             }

  realize Group['www-data']
  realize User['www-data']
  realize Apt::Source[$repository]

  package { 'uitdatabank-search-api':
    ensure  => $version,
    notify  => [Service['uitdatabank-search-api'], Class['profiles::uitdatabank::search_api::listeners'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uitdatabank-search-api-config':
    ensure => 'file',
    path   => "${basedir}/config.yml",
    source => $config_source,
    *      => $file_default_attributes
  }

  file { 'uitdatabank-search-api-features':
    ensure => 'file',
    path   => "${basedir}/features.yml",
    source => $features_source,
    *      => $file_default_attributes
  }

  file { 'uitdatabank-search-api-facet-mapping-regions':
    ensure  => 'file',
    path    => "${basedir}/facet_mapping_regions.yml",
    source  => '/var/www/geojson-data/output/facet_mapping_regions.yml',
    *      => $file_default_attributes
  }

  file { 'uitdatabank-search-api-autocomplete':
    ensure  => 'file',
    path    => "${basedir}/web/autocomplete.json",
    source  => '/var/www/geojson-data/output/autocomplete.json',
    *      => $file_default_attributes
  }

  file { 'uitdatabank-search-api-pubkey-auth0':
    ensure => 'file',
    path   => "${basedir}/public-auth0.pem",
    source => $pubkey_auth0_source,
    *      => $file_default_attributes
  }

  file { 'uitdatabank-search-api-region-mapping':
    ensure => 'file',
    path   => "${basedir}/src/ElasticSearch/Operations/json/mapping_region.json",
    source => $region_mapping_source,
    *      => $file_default_attributes
  }

  if $default_queries_source {
    file { 'uitdatabank-search-api-default-queries':
      ensure => 'file',
      path   => "${basedir}/default_queries.php",
      source => $default_queries_source,
      *      => $file_default_attributes
    }
  }

  profiles::uitdatabank::term_mapping { 'uitdatabank-search-api':
    basedir           => $basedir,
    facilities_source => $facilities_source,
    themes_source     => $themes_source,
    types_source      => $types_source,
    notify            => [Service['uitdatabank-search-api'], Class['profiles::uitdatabank::search_api::listeners']]
  }

  class { 'profiles::uitdatabank::search_api::listeners':
    basedir => $basedir
  }

  profiles::php::fpm_service_alias { 'uitdatabank-search-api': }

  service { 'uitdatabank-search-api':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload uitdatabank-search-api',
    require    => Profiles::Php::Fpm_service_alias['uitdatabank-search-api'],
  }

  cron { 'uitdatabank-search-api-reindex-permanent':
    command     => "${basedir}/bin/app.php udb3-core:reindex-permanent",
    environment => ['MAILTO=infra+cron@publiq.be'],
    hour        => '0',
    minute      => '0',
    require     => Package['uitdatabank-search-api']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
