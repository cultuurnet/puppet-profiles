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

  # Legacy repositories on apt.uitdatabank.be

  case $::operatingsystemrelease {
    '14.04': {
      @apt::source { 'php':
        location => "http://apt.uitdatabank.be/php-legacy-${environment}",
        release  => $facts['os']['distro']['codename'],
        repos    => 'main'
      }

      @apt::source { 'cultuurnet-tools':
        location => "http://apt.uitdatabank.be/tools-legacy-${environment}",
        release  => $facts['os']['distro']['codename'],
        repos    => 'main'
      }
    }
    '16.04': {
      @apt::source { 'php':
        location => "http://apt.uitdatabank.be/php-${environment}",
        release  => $facts['os']['distro']['codename'],
        repos    => 'main'
      }

      @apt::source { 'cultuurnet-tools':
        location => "http://apt.uitdatabank.be/tools-${environment}",
        release  => $facts['os']['distro']['codename'],
        repos    => 'main'
      }
    }
    default: {
      @apt::source { 'cultuurnet-tools':
        location => "http://apt.uitdatabank.be/tools-${environment}",
        release  => $facts['os']['distro']['codename'],
        repos    => 'main'
      }

      @apt::ppa { 'ppa:deadsnakes/ppa': }
    }
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
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'nodejs_14.x':
    location => "http://apt.uitdatabank.be/nodejs_14.x-${environment}",
    release  => $facts['os']['distro']['codename'],
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

  @apt::source { 'erlang':
    location => "http://apt.uitdatabank.be/erlang-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-jenkins':
    location => "http://apt.uitdatabank.be/jenkins-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  # End legacy repositories on apt.uitdatabank.be

  @apt::source { 'aptly':
    location => 'http://repo.aptly.info',
    release  => 'squeeze',
    repos    => 'main'
  }

  @apt::source { 'docker':
    location     => "https://apt.publiq.be/docker-${environment}",
    release      => $facts['os']['distro']['codename'],
    architecture => 'amd64',
    repos        => 'stable'
  }

  @apt::source { 'uit-mail-subscriptions':
    location => "https://apt.publiq.be/uit-mail-subscriptions-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uit-frontend':
    location => "https://apt.publiq.be/uit-frontend-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uit-api':
    location => "https://apt.publiq.be/uit-api-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uit-cms':
    location => "https://apt.publiq.be/uit-cms-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitid-app':
    location => "https://apt.publiq.be/uitid-app-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitid-frontend':
    location => "https://apt.publiq.be/uitid-frontend-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitid-api':
    location => "https://apt.publiq.be/uitid-api-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'widgetbeheer-frontend':
    location => "https://apt.publiq.be/widgetbeheer-frontend-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'projectaanvraag-api':
    location => "https://apt.publiq.be/projectaanvraag-api-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'projectaanvraag-frontend':
    location => "https://apt.publiq.be/projectaanvraag-frontend-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitpas-app':
    location => "https://apt.publiq.be/uitpas-app-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitpas-website-api':
    location => "https://apt.publiq.be/uitpas-website-api-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitpas-website-frontend':
    location => "https://apt.publiq.be/uitpas-website-frontend-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitpas-balie-frontend':
    location => "https://apt.publiq.be/uitpas-balie-frontend-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitpas-balie-api':
    location => "https://apt.publiq.be/uitpas-balie-api-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'curator-articlelinker':
    location => "https://apt.publiq.be/curator-articlelinker-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'newrelic':
    location     => "https://apt.publiq.be/newrelic-${environment}",
    release      => $facts['os']['distro']['codename'],
    architecture => 'amd64',
    repos        => 'non-free'
  }

  @apt::source { 'newrelic-infra':
    location     => "https://apt.publiq.be/newrelic-infra-${environment}",
    release      => $facts['os']['distro']['codename'],
    architecture => 'amd64',
    repos        => 'main'
  }

  @apt::source { 'elastic-8.x':
    location => "https://apt.publiq.be/elastic-8.x-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'nodejs_16':
    location => "http://apt.publiq.be/nodejs_16-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-tools':
    location => "https://apt.publiq.be/publiq-tools-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-tools-xenial':
    location => "https://apt.publiq.be/publiq-tools-xenial-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-versions':
    location => "https://apt.publiq.be/publiq-versions-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-prototypes':
    location => "https://apt.publiq.be/publiq-prototypes-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-infrastructure':
    location => "https://apt.publiq.be/publiq-infrastructure-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-appconfig':
    location => "https://apt.publiq.be/publiq-appconfig-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'museumpas-mspotm':
    location => "https://apt.publiq.be/museumpas-mspotm-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }
}
