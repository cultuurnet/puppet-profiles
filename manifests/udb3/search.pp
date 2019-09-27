class profiles::udb3::search (
) {

  contain ::profiles
  contain ::profiles::elasticsearch
  contain ::deployment::udb3::search

  apt::source { 'cultuurnet-search':
    location => "http://apt.uitdatabank.be/search-${environment}",
    release  => 'trusty',
    repos    => 'main',
    key      => {
      'id'     => '2380EA3E50D3776DFC1B03359F4935C80DC9EA95',
      'source' => 'http://apt.uitdatabank.be/gpgkey/cultuurnet.gpg.key'
    },
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  profiles::apt::update { 'cultuurnet-search':
    require => Apt::Source['cultuurnet-search']
  }

  if $facts['ec2_metadata'] {
    $http_hosts = [ $facts['ipaddress_eth0'], '127.0.0.1']
  } else {
    $http_hosts = [ $facts['ipaddress_eth1'], '127.0.0.1']
  }

  elasticsearch::instance { 'es01':
    'config'  => {
      'http.host'    => $http_hosts,
      'network.host' => [ '127.0.0.1']
    },
    'datadir' => '/data/elasticsearch/es01'
  }

  Class['profiles::elasticsearch'] -> Elasticsearch::Instance['es01']
  Elasticsearch::Instance['es01'] -> Class['deployment::udb3::search']
  Profiles::Apt::Update['cultuurnet-search'] -> Class['deployment::udb3::search']
}
