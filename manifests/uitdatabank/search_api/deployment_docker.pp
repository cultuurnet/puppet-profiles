class profiles::uitdatabank::search_api::deployment_docker (
  String           $config_source,
  String           $pubkey_keycloak_source,
  String           $image,
  String           $aws_region                            = 'eu-west-1',
  Optional[String] $image_tag                             = undef,
  Optional[String] $default_queries_source                = undef,
  Optional[String] $api_keys_matched_to_client_ids_source = undef,
  Optional[String] $puppetdb_url                          = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $config_dir         = '/etc/uitdatabank-search-api'
  $secrets            = lookup('vault:uitdatabank/udb3-search-service')
  $ecr_repository     = regsubst($image, '^[^/]+/', '')
  $resolved_image_tag = pick($image_tag, $facts.dig('docker_image_tag', $ecr_repository), 'latest')

  file { $config_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  class { 'profiles::docker::ecr_repos':
    repos => { $ecr_repository => $aws_region },
  }

  $file_default_attributes = {
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => File[$config_dir],
    notify  => Docker::Compose['uitdatabank-search-api'],
  }

  file { 'uitdatabank-search-api-config':
    path    => "${config_dir}/config.php",
    content => template($config_source),
    *       => $file_default_attributes,
  }

  file { 'uitdatabank-search-api-pubkey-keycloak':
    path    => "${config_dir}/public-keycloak.pem",
    content => template($pubkey_keycloak_source),
    *       => $file_default_attributes,
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
    *       => $file_default_attributes,
  }

  if $default_queries_source {
    file { 'uitdatabank-search-api-default-queries':
      path    => "${config_dir}/default_queries.php",
      content => template($default_queries_source),
      *       => $file_default_attributes,
    }
  }

  file { 'uitdatabank-search-api-docker-compose':
    path    => "${config_dir}/docker-compose.yml",
    content => template('profiles/uitdatabank/search_api/deployment_docker/docker-compose.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$config_dir],
    notify  => Docker::Compose['uitdatabank-search-api'],
  }

  docker::compose { 'uitdatabank-search-api':
    compose_files => ["${config_dir}/docker-compose.yml"],
    pull_on_start => true,
    ensure        => 'present',
    require       => [
      File['uitdatabank-search-api-config'],
      File['uitdatabank-search-api-pubkey-keycloak'],
      File['uitdatabank-search-api-docker-compose'],
    ],
  }

  cron { 'uitdatabank-search-api-reindex-permanent':
    command     => "docker compose -f ${config_dir}/docker-compose.yml exec -T search-api php bin/app.php udb3-core:reindex-permanent",
    environment => ['MAILTO=infra+cron@publiq.be'],
    hour        => '0',
    minute      => '0',
    require     => Docker::Compose['uitdatabank-search-api'],
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
