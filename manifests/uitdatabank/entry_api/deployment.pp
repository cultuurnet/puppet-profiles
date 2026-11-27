class profiles::uitdatabank::entry_api::deployment (
  String                    $config_source,
  String                    $admin_permissions_source,
  String                    $client_permissions_source,
  String                    $movie_fetcher_config_source,
  String                    $completeness_source,
  String                    $externalid_mapping_organizer_source,
  String                    $externalid_mapping_place_source,
  String                    $pubkey_uitidv1_source,
  String                    $pubkey_keycloak_source,
  Optional[String]          $api_keys_matched_to_client_ids_source = undef,
  Enum['present', 'absent'] $amqp_listener_uitpas                  = 'present',
  Enum['present', 'absent'] $bulk_label_offer_worker               = 'present',
  Enum['present', 'absent'] $mail_worker                           = 'present',
  Integer[0]                $event_export_worker_count             = 1
) inherits ::profiles {

  $config_dir              = '/etc/uitdatabank-entry-api'
  $secrets                 = lookup('vault:uitdatabank/udb3-backend')
  $file_default_attributes = {
                               owner   => 'www-data',
                               group   => 'www-data',
                               require => [Group['www-data'], User['www-data']],
                               notify  => Class['profiles::uitdatabank::entry_api::deployment::instance']
                             }

  # Contained, so relationships with this class (from profiles::uitdatabank::entry_api
  # and profiles::uitdatabank::rdf) keep reaching the deployment itself
  class { 'profiles::uitdatabank::entry_api::deployment::instance':
    api_keys_matched_to_client_ids_source => $api_keys_matched_to_client_ids_source,
    amqp_listener_uitpas                  => $amqp_listener_uitpas,
    bulk_label_offer_worker               => $bulk_label_offer_worker,
    mail_worker                           => $mail_worker,
    event_export_worker_count             => $event_export_worker_count
  }

  contain profiles::uitdatabank::entry_api::deployment::instance

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

  file { "${config_dir}/config.allow_all.php":
    ensure  => 'file',
    content => template($admin_permissions_source),
    *       => $file_default_attributes
  }

  file { "${config_dir}/config.client_permissions.php":
    ensure  => 'file',
    content => template($client_permissions_source),
    *       => $file_default_attributes
  }

  file { "${config_dir}/config.api_keys_matched_to_client_ids.php":
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

  file { "${config_dir}/config.kinepolis.php":
    ensure  => 'file',
    content => template($movie_fetcher_config_source),
    *       => $file_default_attributes
  }

  file { "${config_dir}/config.completeness.php":
    ensure  => 'file',
    content => template($completeness_source),
    *       => $file_default_attributes
  }

  file { "${config_dir}/config.external_id_mapping_organizer.php":
    ensure  => 'file',
    content => template($externalid_mapping_organizer_source),
    *       => $file_default_attributes
  }

  file { "${config_dir}/config.external_id_mapping_place.php":
    ensure  => 'file',
    content => template($externalid_mapping_place_source),
    *       => $file_default_attributes
  }

  file { "${config_dir}/public.pem":
    ensure  => 'file',
    content => template($pubkey_uitidv1_source),
    *       => $file_default_attributes
  }

  file { "${config_dir}/public-keycloak.pem":
    ensure  => 'file',
    content => template($pubkey_keycloak_source),
    *       => $file_default_attributes
  }
}
