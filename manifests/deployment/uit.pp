class profiles::deployment::uit {

  include ::profiles::apt_keys

  @apt::source { 'publiq-uit':
    location => "http://apt.uitdatabank.be/uit-${environment}",
    release  => 'xenial',
    repos    => 'main',
    require  => Class['profiles::apt_keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-uit':
    require => Apt::Source['publiq-uit']
  }
}
