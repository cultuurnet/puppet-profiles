class profiles::uitdatabank::entry_api::deployment::container (
  String                              $image,
  Integer[1]                          $fpm_max_children,
  String                              $basedir                        = '/var/www/udb3-backend',
  String                              $aws_region                     = 'eu-west-1',
  Optional[String]                    $image_tag                      = undef,
  Enum['static', 'dynamic', 'ondemand'] $fpm_pm                       = 'static',
  Integer[0]                          $fpm_max_requests               = 10000,
  String                              $upload_max_filesize            = '22M',
  String                              $post_max_size                  = '24M',
  Boolean                             $api_keys_matched_to_client_ids = false,
  Enum['present', 'absent']           $amqp_listener_uitpas           = 'present',
  Enum['present', 'absent']           $bulk_label_offer_worker        = 'present',
  Enum['present', 'absent']           $mail_worker                    = 'present',
  Integer[0]                          $event_export_worker_count      = 1
) inherits ::profiles {

  $config_dir            = '/etc/uitdatabank-entry-api'
  $downloads_dir         = "${basedir}/web/downloads"
  $ecr_repository        = regsubst($image, '^[^/]+/', '')
  $resolved_image_tag    = pick($image_tag, $facts.dig('docker_image_tag', $ecr_repository), 'latest')
  $mount_target_dns_name = lookup('terraform::efs::mount_target_dns_name', Optional[String], 'first', undef)

  include profiles::docker

  class { 'profiles::docker::ecr_repos':
    repos => {
      $ecr_repository => {
        'region'    => $aws_region,
        'image_tag' => $environment
      }
    }
  }

  realize Group['www-data']
  realize User['www-data']

  # Exports are bind mounted into the app, the workers and nginx, so the directory
  # has to exist on the VM whether or not EFS backs it
  if $mount_target_dns_name {
    profiles::nfs::mount { "${mount_target_dns_name}:/":
      mountpoint    => $downloads_dir,
      mount_options => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2',
      owner         => 'www-data',
      group         => 'www-data',
      require       => [User['www-data'], Group['www-data']],
      before        => Exec['uitdatabank-entry-api-docker-compose']
    }
  } else {
    file { $downloads_dir:
      ensure  => 'directory',
      owner   => 'www-data',
      group   => 'www-data',
      require => [User['www-data'], Group['www-data']],
      before  => Exec['uitdatabank-entry-api-docker-compose']
    }
  }

  file { 'uitdatabank-entry-api-fpm-pool':
    ensure  => 'file',
    path    => "${config_dir}/fpm-pool.conf",
    content => template('profiles/uitdatabank/entry_api/deployment/container/fpm-pool.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Exec['uitdatabank-entry-api-docker-compose'],
    notify  => Exec['uitdatabank-entry-api-fpm-pool-reload']
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
    require     => [Class['profiles::docker'], File['uitdatabank-entry-api-docker-compose']],
    notify      => Exec['uitdatabank-entry-api-db-migrate']
  }

  # The instance deployment migrates on package upgrade; here the trigger is the
  # compose file changing, which is what a new image tag does
  exec { 'uitdatabank-entry-api-db-migrate':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml exec -T entry-api vendor/bin/doctrine-dbal --no-interaction migrations:migrate",
    refreshonly => true,
    require     => Exec['uitdatabank-entry-api-docker-compose']
  }

  # SIGUSR2 tells php-fpm's master process to re-read its config and gracefully
  # restart just its workers
  exec { 'uitdatabank-entry-api-fpm-pool-reload':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml kill -s SIGUSR2 entry-api",
    refreshonly => true,
    require     => Exec['uitdatabank-entry-api-docker-compose']
  }

  # SIGHUP tells nginx's master process to re-read its config and gracefully
  # replace its workers, so a config change needs no container recreate
  exec { 'uitdatabank-entry-api-nginx-reload':
    command     => "/usr/bin/docker compose -f ${config_dir}/docker-compose.yml kill -s SIGHUP entry-nginx",
    refreshonly => true,
    require     => Exec['uitdatabank-entry-api-docker-compose']
  }
}
