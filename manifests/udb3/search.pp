class profiles::udb3::search (
  String $elasticsearch_version           = 'latest',
  String $elasticsearch_initial_heap_size = '512m',
  String $elasticsearch_max_heap_size     = '512m'
) {

  contain ::profiles
  contain ::deployment::udb3::search

  include ::profiles::apt::keys
  include ::profiles::apt::updates

  # TODO: parameterize memory settings for instance
  # TODO: move deployment to profiles and rework update_facts stuff
  # TODO: pass parameters from elasticsearch profile here
  # TODO: supervisor + program
  # TODO: apache + vhosts
  # TODO: noop_deploy
  # TODO: unit tests
  # TODO: solution for certificates/HTTPS vhosts
  # TODO: firewall rules

  apt::source { 'cultuurnet-search':
    location => "http://apt.uitdatabank.be/search-${environment}",
    release  => 'trusty',
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  profiles::apt::update { 'cultuurnet-search':
    require => Apt::Source['cultuurnet-search']
  }

  realize Profiles::Apt::Update['nodejs_10.x']

  realize Package['elasticdump']

  if $facts['ec2_metadata'] {
    $http_hosts = [ $facts['ipaddress_eth0'], '127.0.0.1']
  } else {
    $http_hosts = [ $facts['ipaddress_eth1'], '127.0.0.1']
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
      'http.host'    => $http_hosts,
      'network.host' => [ '127.0.0.1']
    }
  }

  Class['profiles::elasticsearch'] -> Elasticsearch::Instance['es01']
  Elasticsearch::Instance['es01'] -> Class['deployment::udb3::search']
  Profiles::Apt::Update['cultuurnet-search'] -> Class['deployment::udb3::search']
}
