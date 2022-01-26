class profiles::jenkins::repositories {

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
}
