class profiles::elasticsearch {

  contain ::profiles
  contain ::profiles::java8

  include ::profiles::repositories

  realize Apt::Source['elasticsearch']
  realize Profiles::Apt::Update['elasticsearch']

  file { '/data/elasticsearch':
    ensure => 'directory'
  }

  sysctl { 'vm.max_map_count':
    value => '262144'
  }
}
