class profiles::uitdatabank::entry_api::deployment (
  String           $config_source,
  String           $admin_permissions_source,
  String           $client_permissions_source,
  String           $pubkey_uitidv1_source,
  String           $pubkey_auth0_source,
  String           $externalid_mapping_organizer_source,
  String           $externalid_mapping_place_source,
  String           $term_mapping_facilities_source,
  String           $term_mapping_themes_source,
  String           $term_mapping_types_source,
  String           $version                             = 'latest',
  String           $repository                          = 'uitdatabank-entry-api',
  Boolean          $bulk_label_offer_worker             = true,
  Boolean          $amqp_listener_uitpas                = true,
  Integer[0]       $event_export_worker_count           = 1,
  Optional[String] $puppetdb_url                        = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir                 = '/var/www/udb3-backend'
  $service_name            = 'uitdatabank-entry-api'
  $file_default_attributes = {
                               ensure  => 'file',
                               owner   => 'www-data',
                               group   => 'www-data',
                               require => [Group['www-data'], User['www-data'], Package['uitdatabank-entry-api']],
                               notify  => Service[$service_name]
                             }

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uitdatabank-entry-api':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [Service[$service_name], Profiles::Deployment::Versions[$title]]
  }

  file { 'uitdatabank-entry-api-config':
    path   => "${basedir}/config.php",
    source => $config_source,
    *      => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-admin-permissions':
    path   => "${basedir}/config.allow_all.php",
    source => $admin_permissions_source,
    *      => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-client-permissions':
    path   => "${basedir}/config.client_permissions.php",
    source => $client_permissions_source,
    *      => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-pubkey-uitidv1':
    path   => "${basedir}/public.pem",
    source => $pubkey_uitidv1_source,
    *      => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-pubkey-auth0':
    path   => "${basedir}/public-auth0.pem",
    source => $pubkey_auth0_source,
    *      => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-externalid-mapping-organizer':
    path   => "${basedir}/config.external_id_mapping_organizer.php",
    source => $externalid_mapping_organizer_source,
    *      => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-externalid-mapping-place':
    path   => "${basedir}/config.external_id_mapping_place.php",
    source => $externalid_mapping_place_source,
    *      => $file_default_attributes
  }

  profiles::uitdatabank::terms { 'uitdatabank-entry-api':
    directory                 => $basedir,
    facilities_mapping_source => $term_mapping_facilities_source,
    themes_mapping_source     => $term_mapping_themes_source,
    types_mapping_source      => $term_mapping_types_source,
    require                   => Package['uitdatabank-entry-api'],
    notify                    => Service[$service_name]
  }

  exec { 'uitdatabank-entry-api-db-migrate':
    command     => 'vendor/bin/doctrine-dbal --no-interaction migrations:migrate',
    cwd         => $basedir,
    path        => [$basedir],
    refreshonly => true,
    subscribe   => Package['uitdatabank-entry-api'],
    notify      => Service[$service_name]
  }

  profiles::php::fpm_service_alias { $service_name: }

  service { $service_name:
    hasstatus  => true,
    hasrestart => true,
    restart    => "/usr/bin/systemctl reload ${service_name}",
    subscribe  => Profiles::Php::Fpm_service_alias[$service_name],
  }

  if $amqp_listener_uitpas {
    systemd::unit_file { 'uitdatabank-amqp-listener-uitpas.service':
      content => template('profiles/uitdatabank/entry_api/uitdatabank-amqp-listener-uitpas.service.erb'),
      notify  => Service['uitdatabank-amqp-listener-uitpas']
    }

    service { 'uitdatabank-amqp-listener-uitpas':
      ensure    => 'running',
      enable    => true,
      hasstatus => true,
      subscribe => Service['uitdatabank-entry-api']
    }
  } else {
    systemd::unit_file { 'uitdatabank-amqp-listener-uitpas.service':
      ensure => 'absent'
    }
  }

  if $bulk_label_offer_worker {
    systemd::unit_file { 'uitdatabank-bulk-label-offer-worker.service':
      content => template('profiles/uitdatabank/entry_api/uitdatabank-bulk-label-offer-worker.service.erb'),
      notify  => Service['uitdatabank-bulk-label-offer-worker']
    }

    service { 'uitdatabank-bulk-label-offer-worker':
      ensure    => 'running',
      enable    => true,
      hasstatus => true,
      subscribe => Service['uitdatabank-entry-api']
    }
  } else {
    systemd::unit_file { 'uitdatabank-bulk-label-offer-worker.service':
      ensure => 'absent'
    }
  }

  if $event_export_worker_count > 0 {
    systemd::unit_file { 'uitdatabank-event-export-worker@.service':
      content => template('profiles/uitdatabank/entry_api/uitdatabank-event-export-worker@.service.erb')
    }

    Integer[1, $event_export_worker_count].each |$id| {
      service { "uitdatabank-event-export-worker@${id}":
        ensure    => 'running',
        enable    => true,
        hasstatus => true,
        subscribe => [Systemd::Unit_file['uitdatabank-event-export-worker@.service'], Service['uitdatabank-entry-api']]
      }
    }

    systemd::unit_file { 'uitdatabank-event-export-workers.target':
      content => template('profiles/uitdatabank/entry_api/uitdatabank-event-export-workers.target.erb'),
      notify  => Service['uitdatabank-event-export-workers']
    }

    service { 'uitdatabank-event-export-workers':
      ensure    => 'running',
      enable    => true,
      hasstatus => true,
      subscribe => Service['uitdatabank-entry-api']
    }
  } else {
    systemd::unit_file { 'uitdatabank-event-export-worker@.service':
      ensure => 'absent'
    }

    systemd::unit_file { 'uitdatabank-event-export-workers.target':
      ensure => 'absent'
    }
  }


  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
