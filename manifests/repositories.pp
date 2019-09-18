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

  @profiles::apt::update { 'cultuurnet-tools':
    require => Apt::Source['cultuurnet-tools']
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

  @apt::source { 'nodejs_8.x':
    location => "http://apt.uitdatabank.be/nodejs_8.x-${environment}",
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

  @apt::source { 'nodejs_10.x':
    location => "http://apt.uitdatabank.be/nodejs_10.x-${environment}",
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

  @apt::source { 'elasticsearch':
    location => "http://apt.uitdatabank.be/elasticsearch-${environment}",
    release  => 'stable',
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

  @profiles::apt::update { 'elasticsearch':
    require => Apt::Source['elasticsearch']
  }

  @apt::source { 'php':
    location => "http://apt.uitdatabank.be/php-${environment}",
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
}
