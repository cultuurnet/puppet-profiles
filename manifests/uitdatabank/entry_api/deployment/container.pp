class profiles::uitdatabank::entry_api::deployment::container (
  String                    $image,
  String                    $basedir                        = '/var/www/udb3-backend',
  String                    $aws_region                     = 'eu-west-1',
  Optional[String]          $image_tag                      = undef,
  Boolean                   $api_keys_matched_to_client_ids = false,
  Enum['present', 'absent'] $amqp_listener_uitpas           = 'present',
  Enum['present', 'absent'] $bulk_label_offer_worker        = 'present',
  Enum['present', 'absent'] $mail_worker                    = 'present',
  Integer[0]                $event_export_worker_count      = 1
) inherits ::profiles {

  $config_dir         = '/etc/uitdatabank-entry-api'
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

  realize Group['www-data']
  realize User['www-data']

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

  file { $webroot:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']]
  }

  file { "${webroot}/.htaccess":
    ensure  => 'file',
    owner   => 'www-data',
    group   => 'www-data',
    content => "RewriteEngine On\nRewriteCond %{REQUEST_FILENAME} !-f\nRewriteRule ^ index.php [QSA,L]\n",
    require => File[$webroot]
  }
}
