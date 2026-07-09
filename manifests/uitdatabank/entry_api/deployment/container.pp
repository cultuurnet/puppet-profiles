class profiles::uitdatabank::entry_api::deployment::container (
  String           $image,
  String           $config_source,
  String           $admin_permissions_source,
  String           $client_permissions_source,
  String           $movie_fetcher_config_source,
  String           $completeness_source,
  String           $externalid_mapping_organizer_source,
  String           $externalid_mapping_place_source,
  String           $pubkey_uitidv1_source,
  String           $pubkey_keycloak_source,
  String           $aws_region                                    = 'eu-west-1',
  Optional[String] $image_tag                                     = undef,
  Optional[String] $api_keys_matched_to_client_ids_source         = undef,
  Enum['present', 'absent'] $amqp_listener_uitpas                 = 'present',
  Enum['present', 'absent'] $bulk_label_offer_worker              = 'present',
  Enum['present', 'absent'] $mail_worker                          = 'present',
  Integer[0]                $event_export_worker_count            = 1,
) inherits ::profiles {
  $config_dir         = '/etc/uitdatabank-entry-api'
  $basedir            = '/var/www/udb3-backend'
  $webroot            = "${basedir}/web"
  $secrets            = lookup('vault:uitdatabank/udb3-backend')
  $ecr_repository     = regsubst($image, '^[^/]+/', '')
  $resolved_image_tag = pick($image_tag, $facts.dig('docker_image_tag', $ecr_repository), 'latest')

  $file_default_attributes = {
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => File[$config_dir],
    notify  => Exec['uitdatabank-entry-api-docker-compose'],
  }

  include profiles::docker

  class { 'profiles::docker::ecr_repos':
    repos => {
      $ecr_repository => {
        'region'    => $aws_region,
        'image_tag' => $environment,
      },
    },
  }

  realize Group['www-data']
  realize User['www-data']

  file { $config_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { 'uitdatabank-entry-api-config':
    ensure  => 'file',
    path    => "${config_dir}/config.php",
    content => template($config_source),
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-entry-api-admin-permissions':
    ensure  => 'file',
    path    => "${config_dir}/config.allow_all.php",
    content => template($admin_permissions_source),
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-entry-api-client-permissions':
    ensure  => 'file',
    path    => "${config_dir}/config.client_permissions.php",
    content => template($client_permissions_source),
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-entry-api-movie-fetcher-config':
    ensure  => 'file',
    path    => "${config_dir}/config.kinepolis.php",
    content => template($movie_fetcher_config_source),
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-entry-api-completeness':
    ensure  => 'file',
    path    => "${config_dir}/config.completeness.php",
    content => template($completeness_source),
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-entry-api-externalid-mapping-organizer':
    ensure  => 'file',
    path    => "${config_dir}/config.externalid_mapping_organizer.php",
    content => template($externalid_mapping_organizer_source),
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-entry-api-externalid-mapping-place':
    ensure  => 'file',
    path    => "${config_dir}/config.externalid_mapping_place.php",
    content => template($externalid_mapping_place_source),
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-entry-api-pubkey-uitidv1':
    ensure  => 'file',
    path    => "${config_dir}/public-uitidv1.pem",
    content => template($pubkey_uitidv1_source),
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-entry-api-pubkey-keycloak':
    ensure  => 'file',
    path    => "${config_dir}/public-keycloak.pem",
    content => template($pubkey_keycloak_source),
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-entry-api-api-keys-matched-to-client-ids':
    ensure  => $api_keys_matched_to_client_ids_source ? {
      undef   => 'absent',
      default => 'file',
    },
    path    => "${config_dir}/api_keys_matched_to_client_ids.php",
    content => $api_keys_matched_to_client_ids_source ? {
      undef   => undef,
      default => template($api_keys_matched_to_client_ids_source),
    },
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-entry-api-docker-compose':
    ensure  => 'file',
    path    => "${config_dir}/docker-compose.yml",
    content => template('profiles/uitdatabank/entry_api/deployment/container/docker-compose.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$config_dir],
    notify  => Exec['uitdatabank-entry-api-docker-compose'],
  }

  exec { 'uitdatabank-entry-api-docker-compose':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml up -d --remove-orphans",
    refreshonly => true,
    require     => [Class['profiles::docker'], File['uitdatabank-entry-api-docker-compose']],
  }

  file { $webroot:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']],
  }

  file { "${webroot}/.htaccess":
    ensure  => 'file',
    owner   => 'www-data',
    group   => 'www-data',
    content => "RewriteEngine On\nRewriteCond %{REQUEST_FILENAME} !-f\nRewriteRule ^ index.php [QSA,L]\n",
    require => File[$webroot],
  }
}
