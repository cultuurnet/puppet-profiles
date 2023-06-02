class profiles::udb3::search (
  String $elasticsearch_version           = '5.2.2',
  String $elasticsearch_initial_heap_size = '512m',
  String $elasticsearch_max_heap_size     = '512m'
) inherits ::profiles {

  contain ::deployment::udb3::search

  include ::profiles::elasticdump

  # TODO: parameterize memory settings for instance
  # TODO: move deployment to profiles and rework update_facts stuff
  # TODO: pass parameters from elasticsearch profile here
  # TODO: supervisor + program
  # TODO: apache + vhosts
  # TODO: noop_deploy
  # TODO: unit tests
  # TODO: solution for certificates/HTTPS vhosts
  # TODO: firewall rules

  if $facts['ec2_metadata'] {
    $interface = 'eth0'
  } else {
    $interface = 'eth1'
  }

  class { 'profiles::elasticsearch':
    version => $elasticsearch_version
  }

  elasticsearch::instance { 'es01':
    ensure      => 'present',
    status      => 'enabled',
    jvm_options => [ "-Xms${elasticsearch_initial_heap_size}", "-Xmx${elasticsearch_max_heap_size}"],
    datadir     => '/data/elasticsearch/es01',
    config      => {
      'http.host'    => [ $facts['networking'][$interface]['ip'], '127.0.0.1'],
      'network.host' => [ '127.0.0.1']
    }
  }

  Class['profiles::elasticsearch'] -> Elasticsearch::Instance['es01']
  Elasticsearch::Instance['es01'] -> Class['deployment::udb3::search']
}
