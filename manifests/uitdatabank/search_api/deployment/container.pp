class profiles::uitdatabank::search_api::deployment::container (
  String           $image,
  String           $basedir                        = '/var/www/udb3-search-service',
  String           $aws_region                     = 'eu-west-1',
  Optional[String] $image_tag                      = undef,
  Boolean          $default_queries                = false,
  Boolean          $api_keys_matched_to_client_ids = false
) inherits ::profiles {

  $config_dir         = '/etc/uitdatabank-search-api'
  $webroot            = "${basedir}/web"
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
    notify  => Exec['uitdatabank-search-api-fpm-pool-reload'],
  }

  docker_compose { 'uitdatabank-search-api':
    ensure        => present,
    compose_files => ["${config_dir}/docker-compose.yml"],
    require       => Class['profiles::docker'],
  }

  # SIGUSR2 tells php-fpm's master process to re-read its config and gracefully
  # restart just its workers
  exec { 'uitdatabank-search-api-fpm-pool-reload':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml kill -s SIGUSR2 search-api",
    refreshonly => true,
    require     => Docker_compose['uitdatabank-search-api'],
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

  cron { 'uitdatabank-search-api-reindex-permanent':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml exec -T search-api php bin/app.php udb3-core:reindex-permanent",
    environment => ['MAILTO=infra+cron@publiq.be'],
    hour        => '0',
    minute      => '0',
    require     => Docker_compose['uitdatabank-search-api'],
  }
}
