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
        default_queries_source                => $default_queries_source,
        require                               => Class['profiles::uitdatabank::search_api::deployment']
      }

      Class['profiles::php'] ~> Class['profiles::uitdatabank::search_api::deployment::instance']
    }
    'container': {
      class { 'profiles::uitdatabank::search_api::deployment::container':
        basedir                        => $basedir,
        api_keys_matched_to_client_ids => !!$api_keys_matched_to_client_ids_source,
        default_queries                => !!$default_queries_source,
        require                        => Class['profiles::uitdatabank::search_api::deployment']
      }
    }
  }

  realize Group['www-data']
  realize User['www-data']

  file { $config_dir:
    ensure => 'directory'
  }

  file { "${config_dir}/config.php":
    ensure  => 'file',
    content => template($config_source),
    *       => $file_default_attributes
  }

  file { "${config_dir}/public-keycloak.pem":
    ensure  => 'file',
    content => template($pubkey_keycloak_source),
    *       => $file_default_attributes
  }

  file { "${config_dir}/mapping_region.json":
    ensure  => 'file',
    content => template($region_mapping_source),
    *       => $file_default_attributes
  }

  file { "${config_dir}/default_queries.php":
    ensure  => $default_queries_source ? {
                 undef   => 'absent',
                 default => 'file'
               },
    content => $default_queries_source ? {
                 undef   => undef,
                 default => template($default_queries_source),
               },
    *       => $file_default_attributes
  }

  file { "${config_dir}/api_keys_matched_to_client_ids.php":
    ensure  => $api_keys_matched_to_client_ids_source ? {
                 undef   => 'absent',
                 default => 'file'
               },
    content => $api_keys_matched_to_client_ids_source ? {
                 undef   => undef,
                 default => template($api_keys_matched_to_client_ids_source),
               },
    *       => $file_default_attributes
  }
}
