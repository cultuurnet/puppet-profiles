class profiles::repositories {

  # TODO: repositories split for trusty and xenial

  include ::profiles::apt_keys

  Apt::Source {
    require => Class['profiles::apt_keys'],
    include => {
      'deb' => true,
      'src' => false
    }
  }

  @apt::source { 'cultuurnet-tools':
    location => "http://apt.uitdatabank.be/tools-${environment}",
    release  => $facts['lsbdistcodename'],
    repos    => 'main'
  }

  @profiles::apt::update { 'cultuurnet-tools':
    require => Apt::Source['cultuurnet-tools']
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

  @apt::source { 'nodejs_12.x':
    location => "http://apt.uitdatabank.be/nodejs_12.x-${environment}",
    release  => 'trusty',
    repos    => 'main'
  }

  @profiles::apt::update { 'nodejs_12.x':
    require => Apt::Source['nodejs_12.x']
  }

  @apt::source { 'nodejs_14.x':
    location => "http://apt.uitdatabank.be/nodejs_14.x-${environment}",
    release  => 'trusty',
    repos    => 'main'
  }

  @profiles::apt::update { 'nodejs_14.x':
    require => Apt::Source['nodejs_14.x']
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
