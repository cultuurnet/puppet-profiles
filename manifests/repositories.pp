class profiles::repositories {

  # TODO: repositories split for trusty and xenial

  Apt::Source {
    require => Apt::Key['Infra CultuurNet'],
    include => {
      'deb' => true,
      'src' => false
    }
  }

  apt::key { 'Infra CultuurNet':
    id     => '2380EA3E50D3776DFC1B03359F4935C80DC9EA95',
    server => 'keyserver.ubuntu.com',
    source => 'http://apt.uitdatabank.be/gpgkey/cultuurnet.gpg.key'
  }

  @apt::source { 'cultuurnet-tools':
    location => "http://apt.uitdatabank.be/tools-${environment}",
    release  => $facts['lsbdistcodename'],
    repos    => 'main'
  }

  @profiles::apt::update { 'cultuurnet-tools':
    require => Apt::Source['cultuurnet-tools']
  }


  @apt::source { 'publiq-infrastructure':
    location => "http://apt.publiq.be/infrastructure-${environment}",
    release  => $facts['lsbdistcodename'],
    repos    => 'main'
  }

  @profiles::apt::update { 'publiq-infrastructure':
    require => Apt::Source['publiq-infrastructure']
  }


  @apt::source { 'rabbitmq':
    location => "http://apt.uitdatabank.be/rabbitmq-${environment}",
    release  => 'testing',
    repos    => 'main'
  }

  @profiles::apt::update { 'rabbitmq':
    require => Apt::Source['rabbitmq']
  }

  @apt::source { 'nodejs_10.x':
    location => "http://apt.uitdatabank.be/nodejs_10.x-${environment}",
    release  => 'trusty',
    repos    => 'main'
  }

  @profiles::apt::update { 'nodejs_10.x':
    require => Apt::Source['nodejs_10.x']
  }

  @apt::source { 'elasticsearch':
    location => "http://apt.uitdatabank.be/elasticsearch-${environment}",
    release  => 'stable',
    repos    => 'main'
  }

  @profiles::apt::update { 'elasticsearch':
    require => Apt::Source['elasticsearch']
  }

  @apt::source { 'php':
    location => "http://apt.uitdatabank.be/php-${environment}",
    release  => 'trusty',
    repos    => 'main'
  }

  @profiles::apt::update { 'php':
    require => Apt::Source['php']
  }

  @apt::source { 'yarn':
    location => "http://apt.uitdatabank.be/yarn-${environment}",
    release  => 'stable',
    repos    => 'main'
  }

  @profiles::apt::update { 'yarn':
    require => Apt::Source['yarn']
  }
}
