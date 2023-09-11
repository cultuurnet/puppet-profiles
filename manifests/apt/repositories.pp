class profiles::apt::repositories {

  contain ::profiles::apt::keys

  Apt::Source {
    require => Class['profiles::apt::keys'],
    include => {
      'deb' => true,
      'src' => false
    }
  }

  # Ubuntu OS repositories
  case $facts['os']['release']['major'] {
    '20.04': {
      apt::source { 'focal':
        location => "https://apt.publiq.be/focal-${environment}",
        release  => 'focal',
        repos    => 'main'
      }

      apt::source { 'focal-updates':
        location => "https://apt.publiq.be/focal-updates-${environment}",
        release  => 'focal',
        repos    => 'main'
      }

      apt::source { 'focal-security':
        location => "https://apt.publiq.be/focal-security-${environment}",
        release  => 'focal',
        repos    => 'main'
      }

      apt::source { 'focal-backports':
        location => "https://apt.publiq.be/focal-backports-${environment}",
        release  => 'focal',
        repos    => 'main'
      }
    }
  }

  # Tool repositories
  @apt::source { 'aptly':
    location => 'http://repo.aptly.info',
    release  => 'squeeze',
    repos    => 'main'
  }

  @apt::source { 'puppet':
    location => "https://apt.publiq.be/puppet-${facts['os']['distro']['codename']}-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'puppet'
  }

  @apt::source { 'docker':
    location     => "https://apt.publiq.be/docker-${environment}",
    release      => $facts['os']['distro']['codename'],
    architecture => 'amd64',
    repos        => 'stable'
  }

  @apt::source { 'newrelic':
    location     => "https://apt.publiq.be/newrelic-${environment}",
    release      => $facts['os']['distro']['codename'],
    architecture => 'amd64',
    repos        => 'non-free'
  }

  @apt::source { 'newrelic-infra':
    location     => "https://apt.publiq.be/newrelic-infra-$facts['os']['distro']['codename']-${environment}",
    release      => $facts['os']['distro']['codename'],
    architecture => 'amd64',
    repos        => 'main'
  }

  @apt::source { 'elastic-5.x':
    location => "https://apt.publiq.be/elastic-5.x-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'elastic-8.x':
    location => "https://apt.publiq.be/elastic-8.x-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-nodejs-14':
    location => "https://apt.publiq.be/publiq-nodejs-14-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-nodejs-16':
    location => "https://apt.publiq.be/publiq-nodejs-16-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-nodejs-18':
    location => "https://apt.publiq.be/publiq-nodejs-18-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-tools':
    location => "https://apt.publiq.be/publiq-tools-${facts['os']['distro']['codename']}-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'php':
    location => "https://apt.publiq.be/php-${facts['os']['distro']['codename']}-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  # Project repositories
  @apt::source { 'uit-mail-subscriptions':
    location => "https://apt.publiq.be/uit-mail-subscriptions-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uit-notifications':
    location => "https://apt.publiq.be/uit-notifications-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uit-recommender-frontend':
    location => "https://apt.publiq.be/uit-recommender-frontend-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uit-frontend':
    location => "https://apt.publiq.be/uit-frontend-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uit-frontend-nuxt3':
    location => "https://apt.publiq.be/uit-frontend-nuxt3-${environment}",
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

  @apt::source { 'uitpas-balie':
    location => "https://apt.publiq.be/uitpas-balie-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitpas-groepspas-frontend':
    location => "https://apt.publiq.be/uitpas-groepspas-frontend-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-angular-app':
    location => "https://apt.publiq.be/uitdatabank-angular-app-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-newsletter-api':
    location => "https://apt.publiq.be/uitdatabank-newsletter-api-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-search-api':
    location => "https://apt.publiq.be/uitdatabank-search-api-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-geojson-data':
    location => "https://apt.publiq.be/uitdatabank-geojson-data-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-frontend':
    location => "https://apt.publiq.be/uitdatabank-frontend-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-jwt-provider':
    location => "https://apt.publiq.be/uitdatabank-jwt-provider-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-jwt-provider-uitidv1':
    location => "https://apt.publiq.be/uitdatabank-jwt-provider-uitidv1-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-movie-api-fetcher':
    location => "https://apt.publiq.be/uitdatabank-movie-api-fetcher-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-entry-api':
    location => "https://apt.publiq.be/uitdatabank-entry-api-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-websocket-server':
    location => "https://apt.publiq.be/uitdatabank-websocket-server-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'curator-articlelinker':
    location => "https://apt.publiq.be/curator-articlelinker-${environment}",
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

  @apt::source { 'publiq-infrastructure-legacy':
    location => "https://apt.publiq.be/publiq-infrastructure-legacy-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-appconfig':
    location => "https://apt.publiq.be/publiq-appconfig-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'publiq-jenkins':
    location => "https://apt.publiq.be/publiq-jenkins-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'museumpas-mspotm':
    location => "https://apt.publiq.be/museumpas-mspotm-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'museumpas-website':
    location => "https://apt.publiq.be/museumpas-website-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'museumpas-website-filament':
    location => "https://apt.publiq.be/museumpas-website-filament-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }

  @apt::source { 'platform-api':
    location => "https://apt.publiq.be/platform-api-${environment}",
    release  => $facts['os']['distro']['codename'],
    repos    => 'main'
  }
}
