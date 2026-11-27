class profiles::uitdatabank::entry_api::deployment::container (
  String                    $ecr_registry,
  Integer[1]                $fpm_max_children,
  String                    $ecr_repository                 = 'uitdatabank/entry-api',
  String                    $image_tag                      = ecr_docker_image_version_tag("${ecr_registry}/${ecr_repository}", $environment),
  Integer[0]                $fpm_max_requests               = 10000,
  Boolean                   $db_migrate                     = true,
  Boolean                   $api_keys_matched_to_client_ids = false,
  Enum['present', 'absent'] $amqp_listener_uitpas           = 'present',
  Enum['present', 'absent'] $bulk_label_offer_worker        = 'present',
  Enum['present', 'absent'] $mail_worker                    = 'present',
  Integer[0]                $event_export_worker_count      = 1
) inherits ::profiles {

  $config_dir            = '/etc/uitdatabank-entry-api'
  $data_dir              = '/var/lib/uitdatabank-entry-api'
  $downloads_dir         = "${data_dir}/downloads"
  $mount_target_dns_name = lookup('terraform::efs::mount_target_dns_name', Optional[String], 'first', undef)

  include profiles::docker

  realize Group['www-data']
  realize User['www-data']

  # Event exports are written here by the workers and served by nginx, so it
  # lives on the host and is shared by both (and with the instance nodes, when EFS
  # backs it)
  file { [$data_dir, $downloads_dir]:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']],
    before  => Docker_compose['uitdatabank-entry-api']
  }

  if $mount_target_dns_name {
    profiles::nfs::mount { "${mount_target_dns_name}:/":
      mountpoint    => $downloads_dir,
      mount_options => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2',
      owner         => 'www-data',
      group         => 'www-data',
      require       => File[$downloads_dir],
      before        => Docker_compose['uitdatabank-entry-api']
    }
  }

  file { 'uitdatabank-entry-api-docker-compose':
    ensure  => 'file',
    path    => "${config_dir}/docker-compose.yml",
    content => template('profiles/uitdatabank/entry_api/deployment/container/docker-compose.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Docker_compose['uitdatabank-entry-api']
  }

  # The image ships php-fpm's stock pool (pm.max_children = 5). The instance nodes
  # set their pool sizes in Hiera, and so does this class
  file { 'uitdatabank-entry-api-fpm-pool':
    ensure  => 'file',
    path    => "${config_dir}/fpm-pool.conf",
    content => "[www]\npm = static\npm.max_children = ${fpm_max_children}\npm.max_requests = ${fpm_max_requests}\nlisten.backlog = -1\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Docker_compose['uitdatabank-entry-api'],
    notify  => Exec['uitdatabank-entry-api-fpm-pool-reload']
  }

  file { 'uitdatabank-entry-api-nginx-conf':
    ensure  => 'file',
    path    => "${config_dir}/nginx.conf",
    content => template('profiles/uitdatabank/entry_api/deployment/container/nginx.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Docker_compose['uitdatabank-entry-api'],
    notify  => Exec['uitdatabank-entry-api-nginx-reload']
  }

  docker_compose { 'uitdatabank-entry-api':
    ensure        => present,
    compose_files => ["${config_dir}/docker-compose.yml"],
    scale         => $event_export_worker_count ? {
                       0       => undef,
                       default => { 'event-export-worker' => $event_export_worker_count }
                     },
    require       => Class['profiles::docker']
  }

  # A new image tag rewrites the compose file, which is what the package upgrade
  # is on the instance nodes
  if $db_migrate {
    exec { 'uitdatabank-entry-api-db-migrate':
      command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml exec -T entry-api vendor/bin/doctrine-dbal --no-interaction migrations:migrate",
      refreshonly => true,
      subscribe   => File['uitdatabank-entry-api-docker-compose'],
      require     => Docker_compose['uitdatabank-entry-api']
    }
  }

  # SIGUSR2 tells php-fpm's master process to re-read its config and gracefully
  # restart just its workers
  exec { 'uitdatabank-entry-api-fpm-pool-reload':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml kill -s SIGUSR2 entry-api",
    refreshonly => true,
    require     => Docker_compose['uitdatabank-entry-api']
  }

  exec { 'uitdatabank-entry-api-nginx-reload':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml kill -s SIGHUP entry-nginx",
    refreshonly => true,
    require     => Docker_compose['uitdatabank-entry-api']
  }
}
