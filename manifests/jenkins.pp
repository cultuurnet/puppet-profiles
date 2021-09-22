class profiles::jenkins inherits ::profiles {

  include ::profiles::apt::keys

  @apt::source { 'publiq-jenkins':
    location => "http://apt.uitdatabank.be/jenkins-${environment}",
    release  => $facts['lsbdistcodename'],
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-jenkins': }
}
