class profiles::uitdatabank::frontend::deployment::container (
  String                  $config_source,
  String                  $ecr_registry,
  String                  $ecr_repository  = 'uitdatabank/frontend',
  String                  $image_tag       = ecr_docker_image_version_tag("${ecr_registry}/${ecr_repository}", $environment),
  Stdlib::IP::Address::V4 $service_address = '127.0.0.1',
  Integer                 $service_port    = 4000,
) inherits ::profiles {

  $config_dir = '/etc/uitdatabank-frontend'
  $secrets    = lookup('vault:uitdatabank/udb3-frontend')

  include profiles::docker

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
