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

  Class['profiles::elasticsearch'] -> Class['deployment::udb3::search']
  Profiles::Apt::Update['cultuurnet-search'] -> Class['deployment::udb3::search'
}
