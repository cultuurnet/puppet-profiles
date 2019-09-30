class profiles::elasticsearch {

  contain ::profiles
  contain ::profiles::java8

  include ::profiles::repositories

  realize Apt::Source['elasticsearch']
  realize Profiles::Apt::Update['elasticsearch']

  # TODO: parameterize this profile (version, ...)
  # TODO: add /data/backups/elasticsearch directory
  # TODO: add snapshot repositories and backup schedule (maybe in product profile)
  # TODO: unit tests
  # TODO: firewall rules

  file { '/data/elasticsearch':
    ensure => 'directory'
  }

  sysctl { 'vm.max_map_count':
    value => '262144'
  }

  class { 'elasticsearch':
    version           => '5.2.2',
    manage_repo       => false,
    api_timeout       => 30,
    restart_on_change => true,
    instances         => {}
  }

  Profiles::Apt::Update['elasticsearch'] -> Class['elasticsearch']
  File['/data/elasticsearch'] -> Class['elasticsearch']
  Sysctl['vm.max_map_count'] -> Class['elasticsearch']
}
