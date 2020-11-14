class profiles::deployment::curator {

  include ::profiles::apt::keys

  @apt::source { 'publiq-curator':
    location => "http://apt.uitdatabank.be/curator-${environment}",
    release  => 'trusty',
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-curator':
    require => Apt::Source['publiq-curator']
  }
}
