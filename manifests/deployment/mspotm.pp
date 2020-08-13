class profiles::deployment::mspotm {

  include ::profiles::apt_keys

  @apt::source { 'publiq-mspotm':
    location => "http://apt.uitdatabank.be/mspotm-${environment}",
    release  => 'trusty',
    repos    => 'main',
    require  => Class['profiles::apt_keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-mspotm':
    require => Apt::Source['publiq-mspotm']
  }
}
