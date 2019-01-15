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
    location => 'http://www.rabbitmq.com/debian/',
    release  => 'testing',
    repos    => 'main',
    key      => {
      'id'     => '0A9AF2115F4687BD29803A206B73A36E6026DFCA',
      'source' => 'http://www.rabbitmq.com/rabbitmq-release-signing-key.asc'
    },
    include  => {
      'deb' => true,
      'src' => false
    }
  }
}
