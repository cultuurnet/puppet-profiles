class profiles::uitdatabank::entry_api::deployment (
  String                    $config_source,
  String                    $admin_permissions_source,
  String                    $client_permissions_source,
  String                    $movie_fetcher_config_source,
  String                    $completeness_source,
  String                    $externalid_mapping_organizer_source,
  String                    $externalid_mapping_place_source,
  String                    $term_mapping_facilities_source,
  String                    $term_mapping_themes_source,
  String                    $term_mapping_types_source,
  String                    $pubkey_uitidv1_source,
  String                    $pubkey_keycloak_source,
  String                    $version                             = 'latest',
  String                    $repository                          = 'uitdatabank-entry-api',
  Enum['present', 'absent'] $amqp_listener_uitpas                = 'present',
  Enum['present', 'absent'] $bulk_label_offer_worker             = 'present',
  Enum['present', 'absent'] $mail_worker                         = 'present',
  Integer[0]                $event_export_worker_count           = 1,
  Optional[String]          $puppetdb_url                        = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir                 = '/var/www/udb3-backend'
  $secrets                 = lookup('vault:uitdatabank/udb3-backend')
  $mount_target_dns_name   = lookup('terraform::efs::mount_target_dns_name', Optional[String], 'first', undef)
  $file_default_attributes = {
                               ensure  => 'file',
                               owner   => 'www-data',
                               group   => 'www-data',
                               require => [Group['www-data'], User['www-data'], Package['uitdatabank-entry-api']],
                               notify  => Service['uitdatabank-entry-api']
                             }

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uitdatabank-entry-api':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [Service['uitdatabank-entry-api'], Profiles::Deployment::Versions[$title]]
  }

  if $mount_target_dns_name {
    profiles::nfs::mount { "${mount_target_dns_name}:/":
      mountpoint    => "${basedir}/web/downloads",
      mount_options => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2',
      owner         => 'www-data',
      group         => 'www-data',
      require       => [Package['uitdatabank-entry-api'], User['www-data'], Group['www-data']]
    }
  }

  file { 'uitdatabank-entry-api-config':
    path    => "${basedir}/config.php",
    content => template($config_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-admin-permissions':
    path    => "${basedir}/config.allow_all.php",
    content => template($admin_permissions_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-client-permissions':
    path    => "${basedir}/config.client_permissions.php",
    content => template($client_permissions_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-movie-fetcher-config':
    path    => "${basedir}/config.kinepolis.php",
    content => template($movie_fetcher_config_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-completeness':
    path    => "${basedir}/config.completeness.php",
    content => template($completeness_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-externalid-mapping-organizer':
    path    => "${basedir}/config.external_id_mapping_organizer.php",
    content => template($externalid_mapping_organizer_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-externalid-mapping-place':
    path    => "${basedir}/config.external_id_mapping_place.php",
    content => template($externalid_mapping_place_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-pubkey-uitidv1':
    path    => "${basedir}/public.pem",
    content => template($pubkey_uitidv1_source),
    *       => $file_default_attributes
  }

  file { 'uitdatabank-entry-api-pubkey-keycloak':
    path    => "${basedir}/public-keycloak.pem",
    content => template($pubkey_keycloak_source),
    *       => $file_default_attributes
  }

  profiles::uitdatabank::term_mapping { 'uitdatabank-entry-api':
    basedir                     => $basedir,
    facilities_source           => $term_mapping_facilities_source,
    themes_source               => $term_mapping_themes_source,
    types_source                => $term_mapping_types_source,
    facilities_mapping_filename => 'config.term_mapping_facilities.php',
    themes_mapping_filename     => 'config.term_mapping_themes.php',
    types_mapping_filename      => 'config.term_mapping_types.php',
    require                     => Package['uitdatabank-entry-api'],
    notify                      => Service['uitdatabank-entry-api']
  }

  exec { 'uitdatabank-entry-api-db-migrate':
    command     => 'vendor/bin/doctrine-dbal --no-interaction migrations:migrate',
    cwd         => $basedir,
    path        => ['/usr/local/bin', '/usr/bin', '/bin', $basedir],
    refreshonly => true,
    subscribe   => Package['uitdatabank-entry-api'],
    notify      => Service['uitdatabank-entry-api']
  }

  profiles::php::fpm_service_alias { 'uitdatabank-entry-api': }

  service { 'uitdatabank-entry-api':
    hasstatus  => true,
    hasrestart => true,
    restart    => "/usr/bin/systemctl reload uitdatabank-entry-api",
    subscribe  => Profiles::Php::Fpm_service_alias['uitdatabank-entry-api'],
  }

  class { 'profiles::uitdatabank::entry_api::amqp_listener_uitpas':
    ensure    => $amqp_listener_uitpas,
    basedir   => $basedir,
    subscribe => Service['uitdatabank-entry-api']
  }

  class { 'profiles::uitdatabank::entry_api::bulk_label_offer_worker':
    ensure    => $bulk_label_offer_worker,
    basedir   => $basedir,
    subscribe => Service['uitdatabank-entry-api']
  }

  class { 'profiles::uitdatabank::entry_api::mail_worker':
    ensure    => $mail_worker,
    basedir   => $basedir,
    subscribe => Service['uitdatabank-entry-api']
  }

  class { 'profiles::uitdatabank::entry_api::event_export_workers':
    count     => $event_export_worker_count,
    basedir   => $basedir,
    subscribe => Service['uitdatabank-entry-api']
  }

  class { 'profiles::uitdatabank::entry_api::logrotate':
    basedir => $basedir
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
