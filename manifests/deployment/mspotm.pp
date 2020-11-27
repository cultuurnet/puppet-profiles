class profiles::deployment::mspotm {

  include ::profiles::apt::keys

  @apt::source { 'publiq-mspotm':
    location => "http://apt.uitdatabank.be/mspotm-${environment}",
    release  => 'trusty',
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-mspotm': }
}
