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
  Integer[0]                $event_export_worker_count             = 1,
  Enum['instance', 'container'] $type                              = 'instance',
) inherits ::profiles {

  case $type {
    'instance': {
      class { 'profiles::uitdatabank::entry_api::deployment::instance':
        config_source                         => $config_source,
        admin_permissions_source              => $admin_permissions_source,
        client_permissions_source              => $client_permissions_source,
        movie_fetcher_config_source           => $movie_fetcher_config_source,
        completeness_source                   => $completeness_source,
        externalid_mapping_organizer_source   => $externalid_mapping_organizer_source,
        externalid_mapping_place_source       => $externalid_mapping_place_source,
        pubkey_uitidv1_source                 => $pubkey_uitidv1_source,
        pubkey_keycloak_source                => $pubkey_keycloak_source,
        api_keys_matched_to_client_ids_source => $api_keys_matched_to_client_ids_source,
        amqp_listener_uitpas                  => $amqp_listener_uitpas,
        bulk_label_offer_worker               => $bulk_label_offer_worker,
        mail_worker                           => $mail_worker,
        event_export_worker_count             => $event_export_worker_count,
      }
    }
    'container': {
      class { 'profiles::uitdatabank::entry_api::deployment::container':
        config_source                         => $config_source,
        admin_permissions_source              => $admin_permissions_source,
        client_permissions_source              => $client_permissions_source,
        movie_fetcher_config_source           => $movie_fetcher_config_source,
        completeness_source                   => $completeness_source,
        externalid_mapping_organizer_source   => $externalid_mapping_organizer_source,
        externalid_mapping_place_source       => $externalid_mapping_place_source,
        pubkey_uitidv1_source                 => $pubkey_uitidv1_source,
        pubkey_keycloak_source                => $pubkey_keycloak_source,
        api_keys_matched_to_client_ids_source => $api_keys_matched_to_client_ids_source,
        amqp_listener_uitpas                  => $amqp_listener_uitpas,
        bulk_label_offer_worker               => $bulk_label_offer_worker,
        mail_worker                           => $mail_worker,
        event_export_worker_count             => $event_export_worker_count,
      }
    }
  }
}
