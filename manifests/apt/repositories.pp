class profiles::apt::repositories {

  # TODO: repositories split for trusty and xenial

  contain ::profiles::apt::keys

  Apt::Source {
    require => Class['profiles::apt::keys'],
    include => {
      'deb' => true,
      'src' => false
    }
  }

  $php_repository = $facts['lsbdistcodename'] ? {
    'trusty' => 'php-legacy',
    'xenial' => 'php'
  }

  $tools_repository = $facts['lsbdistcodename'] ? {
    'trusty' => 'tools-legacy',
    'xenial' => 'tools'
  }

  @apt::source { 'cultuurnet-tools':
    location => "http://apt.uitdatabank.be/${tools_repository}-${environment}",
    release  => $facts['lsbdistcodename'],
    repos    => 'main'
  }

  @apt::source { 'php':
    location => "http://apt.uitdatabank.be/${php_repository}-${environment}",
    release  => $facts['lsbdistcodename'],
    repos    => 'main'
  }

  @apt::source { 'rabbitmq':
    location => "http://apt.uitdatabank.be/rabbitmq-${environment}",
    release  => 'testing',
    repos    => 'main'
  }

  @apt::source { 'nodejs_10.x':
    location => "http://apt.uitdatabank.be/nodejs_10.x-${environment}",
    release  => 'trusty',
    repos    => 'main'
  }

  @apt::source { 'nodejs_12.x':
    location => "http://apt.uitdatabank.be/nodejs_12.x-${environment}",
    release  => $facts['lsbdistcodename'],
    repos    => 'main'
  }

  @apt::source { 'nodejs_14.x':
    location => "http://apt.uitdatabank.be/nodejs_14.x-${environment}",
    release  => 'trusty',
    repos    => 'main'
  }

  @apt::source { 'nodejs_16.x':
    location => "http://apt.uitdatabank.be/nodejs_16.x-${environment}",
    release  => 'xenial',
    repos    => 'main'
  }

  @apt::source { 'elasticsearch':
    location => "http://apt.uitdatabank.be/elasticsearch-${environment}",
    release  => 'stable',
    repos    => 'main'
  }

  @apt::source { 'yarn':
    location => "http://apt.uitdatabank.be/yarn-${environment}",
    release  => 'stable',
    repos    => 'main'
  }

  @apt::source { 'aptly':
    location => 'http://repo.aptly.info',
    release  => 'squeeze',
    repos    => 'main'
  }
}
