class profiles::deployment::uitpas_be {

  include ::profiles::apt::keys

  @apt::source { 'publiq-uitpasbe':
    location => "http://apt.uitdatabank.be/uitpas.be-${environment}",
    release  => 'trusty',
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-uitpasbe':
    require => Apt::Source['publiq-uitpasbe']
  }
}
