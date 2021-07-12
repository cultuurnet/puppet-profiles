class profiles::deployment::uit {

  include ::profiles::apt::keys

  @apt::source { 'publiq-uit':
    location => "http://apt.uitdatabank.be/uit-${environment}",
    release  => $facts['lsbdistcodename'],
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-uit': }
}
