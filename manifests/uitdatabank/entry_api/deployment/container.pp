class profiles::uitdatabank::entry_api::deployment::container (
  String                    $image,
  String                    $aws_region                     = 'eu-west-1',
  Optional[String]          $image_tag                      = undef,
  Boolean                   $api_keys_matched_to_client_ids = false,
  Enum['present', 'absent'] $amqp_listener_uitpas           = 'present',
  Enum['present', 'absent'] $bulk_label_offer_worker        = 'present',
  Enum['present', 'absent'] $mail_worker                    = 'present',
  Integer[0]                $event_export_worker_count      = 1
) inherits ::profiles {

  $config_dir         = '/etc/uitdatabank-entry-api'
  $ecr_repository     = regsubst($image, '^[^/]+/', '')
  $resolved_image_tag = pick($image_tag, $facts.dig('docker_image_tag', $ecr_repository), 'latest')

  include profiles::docker

  class { 'profiles::docker::ecr_repos':
    repos => {
      $ecr_repository => {
        'region'    => $aws_region,
        'image_tag' => $environment
      }
    }
  }

  file { 'uitdatabank-entry-api-docker-compose':
    ensure  => 'file',
    path    => "${config_dir}/docker-compose.yml",
    content => template('profiles/uitdatabank/entry_api/deployment/container/docker-compose.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Exec['uitdatabank-entry-api-docker-compose']
  }

  exec { 'uitdatabank-entry-api-docker-compose':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml up -d --remove-orphans",
    refreshonly => true,
    require     => [Class['profiles::docker'], File['uitdatabank-entry-api-docker-compose']]
  }

  file { 'uitdatabank-entry-api-nginx-conf':
    ensure  => 'file',
    path    => "${config_dir}/nginx.conf",
    content => template('profiles/uitdatabank/entry_api/deployment/container/nginx.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Exec['uitdatabank-entry-api-docker-compose'],
    notify  => Exec['uitdatabank-entry-api-nginx-reload']
  }

  # SIGHUP tells nginx's master process to re-read its config and gracefully
  # replace its workers, so a config change needs no container recreate
  exec { 'uitdatabank-entry-api-nginx-reload':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml kill -s SIGHUP entry-nginx",
    refreshonly => true,
    require     => Exec['uitdatabank-entry-api-docker-compose']
  }
}
