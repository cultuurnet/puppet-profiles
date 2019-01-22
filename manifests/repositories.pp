class profiles::repositories {

  @apt::source { 'cultuurnet-tools':
    location => "http://apt.uitdatabank.be/tools-${environment}",
    release  => $facts['lsbdistcodename'],
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

  @apt::source { 'rabbitmq':
    location => "http://apt.uitdatabank.be/rabbitmq-${environment}",
    release  => 'testing',
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
}
