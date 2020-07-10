class profiles::deployment::curator {

  include profiles::repositories

  @apt::source { 'publiq-curator':
    location => "http://apt.uitdatabank.be/curator-${environment}",
    release  => 'trusty',
    repos    => 'main',
    require  => Apt::Key['Infra CultuurNet'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-curator':
    require => Apt::Source['publiq-curator']
  }
}
