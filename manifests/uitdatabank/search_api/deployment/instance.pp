class profiles::uitdatabank::search_api::deployment::instance (
  String           $version                               = 'latest',
  String           $repository                            = 'uitdatabank-search-api',
  Optional[String] $default_queries_source                = undef,
  Optional[String] $api_keys_matched_to_client_ids_source = undef,
) inherits ::profiles {

  $config_dir              = '/etc/uitdatabank-search-api'
  $basedir                 = '/var/www/udb3-search-service'

  $file_default_attributes = {
                               require => Package['uitdatabank-search-api'],
                               notify  => [Service['uitdatabank-search-api'], Class['profiles::uitdatabank::search_api::listeners']]
                             }

  realize Apt::Source[$repository]

  package { 'uitdatabank-search-api':
    ensure  => $version,
    notify  => [Service['uitdatabank-search-api'], Class['profiles::uitdatabank::search_api::listeners']],
    require => Apt::Source[$repository]
  }

  file { "${basedir}/config.php":
    ensure => 'link',
    target => "${config_dir}/config.php",
    *      => $file_default_attributes
  }

  file { "${config_dir}/facet_mapping_regions.php":
    ensure => 'link',
    target => '/var/www/geojson-data/output/facet_mapping_regions.php',
    *      => $file_default_attributes
  }

  file { "${basedir}/facet_mapping_regions.php":
    ensure => 'link',
    target => '/var/www/geojson-data/output/facet_mapping_regions.php',
    *      => $file_default_attributes
  }

  file { "${basedir}/web/autocomplete.json":
    ensure => 'link',
    target => '/var/www/geojson-data/output/autocomplete.json',
    *      => $file_default_attributes
  }

  file { "${basedir}/public-keycloak.pem":
    ensure => 'link',
    target => "${config_dir}/public-keycloak.pem",
    *      => $file_default_attributes
  }

  file { "${basedir}/src/ElasticSearch/Operations/json/mapping_region.json":
    ensure => 'link',
    target => "${config_dir}/mapping_region.json",
    *      => $file_default_attributes
  }

  file { "${basedir}/default_queries.php":
    ensure => $default_queries_source ? {
                 undef   => 'absent',
                 default => 'link'
               },
    target => "${config_dir}/default_queries.php",
    *      => $file_default_attributes
  }

  file { "${basedir}/api_keys_matched_to_client_ids.php":
    ensure => $api_keys_matched_to_client_ids_source ? {
                 undef   => 'absent',
                 default => 'link'
               },
    target => "${config_dir}/api_keys_matched_to_client_ids.php",
    *      => $file_default_attributes
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
}
