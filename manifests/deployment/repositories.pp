class profiles::deployment::repositories {

  contain ::profiles::apt::keys

  Apt::Source {
    release => $facts['os']['distro']['codename'],
    repos   => 'main',
    include => {
      'deb' => true,
      'src' => false
    },
    require => Class['profiles::apt::keys']
  }

  @apt::source { 'publiq-uitidv2':
    location => "http://apt.uitdatabank.be/uitidv2-${environment}"
  }

  @apt::source { 'publiq-uitpasbe':
    location => "http://apt.uitdatabank.be/uitpas.be-${environment}"
  }
}
