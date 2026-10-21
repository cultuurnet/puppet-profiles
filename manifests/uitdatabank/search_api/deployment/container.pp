class profiles::uitdatabank::search_api::deployment::container (
  String           $ecr_registry,
  String           $ecr_repository                 = 'uitdatabank/search-api',
  String           $image_tag                      = ecr_docker_image_version_tag("${ecr_registry}/${ecr_repository}", $environment),
  String           $basedir                        = '/var/www/udb3-search-service',
  Boolean          $default_queries                = false,
  Boolean          $api_keys_matched_to_client_ids = false,
  Integer[1]       $cli_worker_count               = 1
) inherits ::profiles {

  $config_dir = '/etc/uitdatabank-search-api'

  include profiles::docker

  file { 'uitdatabank-search-api-docker-compose':
    ensure  => 'file',
    path    => "${config_dir}/docker-compose.yml",
    content => template('profiles/uitdatabank/search_api/deployment/container/docker-compose.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Docker_compose['uitdatabank-search-api'],
  }

  file { 'uitdatabank-search-api-fpm-pool':
    ensure  => 'file',
    path    => "${config_dir}/fpm-pool.conf",
    content => "[www]\npm = static\npm.max_children = 192\npm.max_requests = 10000\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Docker_compose['uitdatabank-search-api'],
    notify  => Exec['uitdatabank-search-api-fpm-pool-reload'],
  }

  docker_compose { 'uitdatabank-search-api':
    ensure        => present,
    compose_files => ["${config_dir}/docker-compose.yml"],
    scale         => { 'search-consume-udb3-cli' => $cli_worker_count },
    require       => Class['profiles::docker'],
  }

  # SIGUSR2 tells php-fpm's master process to re-read its config and gracefully
  # restart just its workers
  exec { 'uitdatabank-search-api-fpm-pool-reload':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml kill -s SIGUSR2 search-api",
    refreshonly => true,
    require     => Docker_compose['uitdatabank-search-api'],
  }

  file { 'uitdatabank-search-api-nginx-conf':
    ensure  => 'file',
    path    => "${config_dir}/nginx.conf",
    content => template('profiles/uitdatabank/search_api/deployment/container/nginx.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Docker_compose['uitdatabank-search-api'],
    notify  => Exec['uitdatabank-search-api-nginx-reload'],
  }

  exec { 'uitdatabank-search-api-nginx-reload':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml kill -s SIGHUP search-nginx",
    refreshonly => true,
    require     => Docker_compose['uitdatabank-search-api'],
  }

  cron { 'uitdatabank-search-api-reindex-permanent':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml exec -T search-api php bin/app.php udb3-core:reindex-permanent",
    environment => ['MAILTO=infra+cron@publiq.be'],
    hour        => '0',
    minute      => '0',
    require     => Docker_compose['uitdatabank-search-api'],
  }
}
