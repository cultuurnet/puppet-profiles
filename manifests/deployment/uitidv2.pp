class profiles::deployment::uitidv2 {

  include ::profiles::apt::keys

  @apt::source { 'publiq-uitidv2':
    location => "http://apt.uitdatabank.be/uitidv2-${environment}",
    release  => 'trusty',
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-uitidv2': }
}
