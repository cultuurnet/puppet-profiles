class profiles::uitdatabank::frontend::deployment::container (
  String                   $image,
  String                   $config_source,
  String                   $aws_region       = 'eu-west-1',
  Optional[String]         $image_tag        = undef,
  Stdlib::IP::Address::V4  $service_address  = '127.0.0.1',
  Integer                  $service_port     = 4000,
) inherits ::profiles {

  $config_dir         = '/etc/uitdatabank-frontend'
  $secrets            = lookup('vault:uitdatabank/udb3-frontend')
  $ecr_repository     = regsubst($image, '^[^/]+/', '')
  $resolved_image_tag = pick($image_tag, $facts.dig('docker_image_tag', $ecr_repository), 'latest')

  include profiles::docker

  class { 'profiles::docker::ecr_repos':
    repos => {
      $ecr_repository => {
        'region'    => $aws_region,
        'image_tag' => $environment,
      },
    },
  }

  file { $config_dir:
    ensure => 'directory',
  }

  file { 'uitdatabank-frontend-env':
    ensure  => 'file',
    path    => "${config_dir}/env",
    content => template($config_source),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => File[$config_dir],
    notify  => Docker_compose['uitdatabank-frontend'],
  }

  file { 'uitdatabank-frontend-docker-compose':
    ensure  => 'file',
    path    => "${config_dir}/docker-compose.yml",
    content => template('profiles/uitdatabank/frontend/deployment/container/docker-compose.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$config_dir],
    notify  => Docker_compose['uitdatabank-frontend'],
  }

  docker_compose { 'uitdatabank-frontend':
    ensure        => present,
    compose_files => ["${config_dir}/docker-compose.yml"],
    require       => Class['profiles::docker'],
  }
}
