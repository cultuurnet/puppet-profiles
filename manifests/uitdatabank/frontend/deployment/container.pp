class profiles::uitdatabank::frontend::deployment::container (
  String  $ecr_registry,
  String  $ecr_repository = 'uitdatabank/frontend',
  String  $image_tag      = ecr_docker_image_version_tag("${ecr_registry}/${ecr_repository}", $environment),
  Integer $service_port   = 4000,
) inherits ::profiles {

  $config_dir = '/etc/uitdatabank-frontend'

  include profiles::docker

  file { 'uitdatabank-frontend-docker-compose':
    ensure  => 'file',
    path    => "${config_dir}/docker-compose.yml",
    content => template('profiles/uitdatabank/frontend/deployment/container/docker-compose.yml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Docker_compose['uitdatabank-frontend'],
  }

  docker_compose { 'uitdatabank-frontend':
    ensure        => present,
    compose_files => ["${config_dir}/docker-compose.yml"],
    require       => Class['profiles::docker'],
  }
}
