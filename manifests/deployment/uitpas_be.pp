class profiles::deployment::uitpas_be {

  @apt::source { 'publiq-uitpas.be':
    location => "http://apt.uitdatabank.be/uitpas.be-${environment}",
    release  => 'trusty',
    repos    => 'main',
    key      => {
      'id'     => '2380EA3E50D3776DFC1B03359F4935C80DC9EA95',
      'source' => 'http://apt.uitdatabank.be/gpgkey/cultuurnet.gpg.key'
    },
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  @profiles::apt::update { 'publiq-uitpas.be':
    require => Apt::Source['publiq-uitpas.be']
  }
}
