class profiles::uitdatabank::search_api::deployment::container (
  String           $image,
  String           $aws_region = 'eu-west-1',
  Optional[String] $image_tag  = undef,
) inherits ::profiles {
  $config_dir         = '/etc/uitdatabank-search-api'
  $ecr_repository     = regsubst($image, '^[^/]+/', '')
  $resolved_image_tag = pick($image_tag, $facts.dig('docker_image_tag', $ecr_repository), 'latest')

  class { 'profiles::docker::ecr_repos':
    repos => {
      $ecr_repository => {
        'region'    => $aws_region,
        'image_tag' => $environment,
      },
    },
  }

  file { 'uitdatabank-search-api-docker-compose':
    ensure  => 'file',
    path    => "${config_dir}/docker-compose.yml",
    content => template('profiles/uitdatabank/search_api/deployment/container/docker-compose.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$config_dir],
    notify  => Docker::Compose['uitdatabank-search-api'],
  }

  docker::compose { 'uitdatabank-search-api':
    ensure        => 'present',
    compose_files => ["${config_dir}/docker-compose.yml"],
    pull_on_start => true,
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
}
