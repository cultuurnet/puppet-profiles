class profiles::uitdatabank::search_api::deployment (
  String                        $config_source,
  String                        $pubkey_keycloak_source,
  Enum['instance', 'container'] $type                                  = 'instance',
  String                        $basedir                               = '/var/www/udb3-search-service',
  String                        $region_mapping_source                 = 'profiles/uitdatabank/search_api/mapping_region.json',
  Optional[String]              $default_queries_source                = undef,
  Optional[String]              $api_keys_matched_to_client_ids_source = undef,
) inherits ::profiles {

  $config_dir              = '/etc/uitdatabank-search-api'
  $secrets                 = lookup('vault:uitdatabank/udb3-search-service')
  $file_default_attributes = {
                               owner   => 'www-data',
                               group   => 'www-data',
                               require => [Group['www-data'], User['www-data']],
                               notify  => Class["profiles::uitdatabank::search_api::deployment::${type}"]
                             }

  case $type {
    'instance': {
      include profiles::php

      class { 'profiles::uitdatabank::search_api::deployment::instance':
        api_keys_matched_to_client_ids_source => $api_keys_matched_to_client_ids_source,
        default_queries_source                => $default_queries_source
      }

      Class['profiles::php'] ~> Class['profiles::uitdatabank::search_api::deployment::instance']
    }
    'container': {
      class { 'profiles::uitdatabank::search_api::deployment::container':
        basedir                        => $basedir,
        api_keys_matched_to_client_ids => !!$api_keys_matched_to_client_ids_source,
        default_queries                => !!$default_queries_source
      }
    }
  }

  realize Group['www-data']
  realize User['www-data']

  file { $config_dir:
    ensure => 'directory'
  }

  file { 'uitdatabank-search-api-config':
    ensure  => 'file',
    path    => "${config_dir}/config.php",
    content => template($config_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-search-api-pubkey-keycloak':
    ensure  => 'file',
    path    => "${config_dir}/public-keycloak.pem",
    content => template($pubkey_keycloak_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-search-api-region-mapping':
    ensure  => 'file',
    path    => "${config_dir}/mapping_region.json",
    content => template($region_mapping_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-search-api-default-queries':
    ensure  => $default_queries_source ? {
                 undef   => 'absent',
                 default => 'file'
               },
    path    => "${config_dir}/default_queries.php",
    content => $default_queries_source ? {
                 undef   => undef,
                 default => template($default_queries_source),
               },
    *       => $file_default_attributes
  }

  file { 'uitdatabank-search-api-api-keys-matched-to-client-ids':
    ensure  => $api_keys_matched_to_client_ids_source ? {
                 undef   => 'absent',
                 default => 'file'
               },
    path    => "${config_dir}/api_keys_matched_to_client_ids.php",
    content => $api_keys_matched_to_client_ids_source ? {
                 undef   => undef,
                 default => template($api_keys_matched_to_client_ids_source),
               },
    *       => $file_default_attributes
  }
}
