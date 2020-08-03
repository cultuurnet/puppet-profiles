class profiles::deployment::uitidv2 {

  include ::profiles::apt_keys

  @apt::source { 'publiq-uitidv2':
    location => "http://apt.uitdatabank.be/uitidv2-${environment}",
    release  => 'trusty',
    repos    => 'main',
    require  => Class['profiles::apt_keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-uitidv2':
    require => Apt::Source['publiq-uitidv2']
  }
}
