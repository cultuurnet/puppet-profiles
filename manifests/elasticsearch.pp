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

  if $facts['ec2_metadata'] {
    $http_hosts = [ $facts['ipaddress_eth0'], '127.0.0.1']
  } else {
    $http_hosts = [ $facts['ipaddress_eth1'], '127.0.0.1']
  }

  class { 'elasticsearch':
    version              => '5.2.2',
    manage_repo          => false,
    api_timeout          => 30,
    restart_on_change    => true,
    status               => 'running',
    jvm_options          => [ '-Xms768m', '-Xmx768m'],
    instances            => {
      'es01' => {
        'config'  => {
          'http.host'    => $http_hosts,
          'network.host' => [ '127.0.0.1']
        },
        'datadir' => '/data/elasticsearch/es01'
      }
    }
  }

  Profiles::Apt::Update['elasticsearch'] -> Class['elasticsearch']
  File['/data/elasticsearch'] -> Class['elasticsearch']
  Sysctl['vm.max_map_count'] -> Class['elasticsearch']
}
