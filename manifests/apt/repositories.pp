class profiles::apt::repositories {

  contain ::profiles::apt::keys

  Apt::Source {
    require => Class['profiles::apt::keys'],
    include => {
      'deb' => true,
      'src' => false
    }
  }

  $codename = $facts['os']['distro']['codename']
  $arch     = $facts['os']['architecture'] ? {
    'amd64'   => 'amd64',
    'aarch64' => 'arm64'
  }

  # Ubuntu OS repositories
  case $facts['os']['release']['major'] {
    '20.04': {
      apt::source { 'focal':
        location => "https://apt-mirror.publiq.be/focal-${arch}-${environment}",
        release  => 'focal',
        repos    => 'main'
      }

      apt::source { 'focal-updates':
        location => "https://apt-mirror.publiq.be/focal-updates-${arch}-${environment}",
        release  => 'focal-updates',
        repos    => 'main'
      }

      apt::source { 'focal-security':
        location => "https://apt-mirror.publiq.be/focal-security-${arch}-${environment}",
        release  => 'focal-security',
        repos    => 'main'
      }

      apt::source { 'focal-backports':
        location => "https://apt-mirror.publiq.be/focal-backports-${arch}-${environment}",
        release  => 'focal-backports',
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

  @apt::source { 'publiq-tools':
    location => "https://apt.publiq.be/publiq-tools-${codename}-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  # Mirrors
  @apt::source { 'docker':
    location     => "https://apt-mirror.publiq.be/docker-${codename}-${environment}",
    release      => $codename,
    architecture => $arch,
    repos        => 'stable'
  }

  @apt::source { 'elastic-5.x':
    location => "https://apt-mirror.publiq.be/elastic-5.x-${environment}",
    release  => 'stable',
    repos    => 'main'
  }

  @apt::source { 'elastic-8.x':
    location     => "https://apt-mirror.publiq.be/elastic-8.x-${environment}",
    release      => 'stable',
    architecture => $arch,
    repos        => 'main'
  }

  @apt::source { 'newrelic':
    location     => "https://apt-mirror.publiq.be/newrelic-${environment}",
    release      => 'newrelic',
    architecture => $arch,
    repos        => 'non-free'
  }

  @apt::source { 'newrelic-infra':
    location     => "https://apt-mirror.publiq.be/newrelic-infra-${codename}-${environment}",
    release      => $codename,
    architecture => $arch,
    repos        => 'main'
  }

  @apt::source { 'nodejs-16':
    location     => "https://apt-mirror.publiq.be/nodejs-16-${environment}",
    release      => 'nodistro',
    architecture => $arch,
    repos        => 'main'
  }

  @apt::source { 'nodejs-18':
    location     => "https://apt-mirror.publiq.be/nodejs-18-${environment}",
    release      => 'nodistro',
    architecture => $arch,
    repos        => 'main'
  }

  @apt::source { 'nodejs-20':
    location     => "https://apt-mirror.publiq.be/nodejs-20-${environment}",
    release      => 'nodistro',
    architecture => $arch,
    repos        => 'main'
  }

  @apt::source { 'php':
    location     => "https://apt-mirror.publiq.be/php-${codename}-${environment}",
    release      => $codename,
    architecture => $arch,
    repos        => 'main'
  }

  @apt::source { 'puppet':
    location     => "https://apt-mirror.publiq.be/puppet-${codename}-${environment}",
    release      => $codename,
    architecture => $arch,
    repos        => 'puppet'
  }

  @apt::source { 'hashicorp':
    location     => "https://apt-mirror.publiq.be/hashicorp-${codename}-${environment}",
    release      => $codename,
    architecture => $arch,
    repos        => 'main'
  }

  # Project repositories
  @apt::source { 'uit-mail-subscriptions':
    location => "https://apt.publiq.be/uit-mail-subscriptions-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uit-notifications':
    location => "https://apt.publiq.be/uit-notifications-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uit-recommender-frontend':
    location => "https://apt.publiq.be/uit-recommender-frontend-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uit-frontend':
    location => "https://apt.publiq.be/uit-frontend-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uit-api':
    location => "https://apt.publiq.be/uit-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uit-cms':
    location => "https://apt.publiq.be/uit-cms-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitid-app':
    location => "https://apt.publiq.be/uitid-app-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitid-frontend':
    location => "https://apt.publiq.be/uitid-frontend-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitid-frontend-api':
    location => "https://apt.publiq.be/uitid-frontend-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitid-frontend-auth0':
    location => "https://apt.publiq.be/uitid-frontend-auth0-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitid-frontend-keycloak':
    location => "https://apt.publiq.be/uitid-frontend-keycloak-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitid-frontend-api-keycloak':
    location => "https://apt.publiq.be/uitid-frontend-api-keycloak-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitid-api':
    location => "https://apt.publiq.be/uitid-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'widgetbeheer-frontend':
    location => "https://apt.publiq.be/widgetbeheer-frontend-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'projectaanvraag-api':
    location => "https://apt.publiq.be/projectaanvraag-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'projectaanvraag-frontend':
    location => "https://apt.publiq.be/projectaanvraag-frontend-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitpas-app':
    location => "https://apt.publiq.be/uitpas-app-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitpas-website-api':
    location => "https://apt.publiq.be/uitpas-website-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitpas-api':
    location => "https://apt.publiq.be/uitpas-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitpas-website-frontend':
    location => "https://apt.publiq.be/uitpas-website-frontend-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitpas-balie-frontend':
    location => "https://apt.publiq.be/uitpas-balie-frontend-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitpas-balie-api':
    location => "https://apt.publiq.be/uitpas-balie-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitpas-balie':
    location => "https://apt.publiq.be/uitpas-balie-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitpas-cid-web':
    location => "https://apt.publiq.be/uitpas-cid-web-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitpas-groepspas-frontend':
    location => "https://apt.publiq.be/uitpas-groepspas-frontend-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-angular-app':
    location => "https://apt.publiq.be/uitdatabank-angular-app-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-newsletter-api':
    location => "https://apt.publiq.be/uitdatabank-newsletter-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-search-api':
    location => "https://apt.publiq.be/uitdatabank-search-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-geojson-data':
    location => "https://apt.publiq.be/uitdatabank-geojson-data-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-frontend':
    location => "https://apt.publiq.be/uitdatabank-frontend-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-jwt-provider':
    location => "https://apt.publiq.be/uitdatabank-jwt-provider-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-jwt-provider-uitidv1':
    location => "https://apt.publiq.be/uitdatabank-jwt-provider-uitidv1-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-movie-api-fetcher':
    location => "https://apt.publiq.be/uitdatabank-movie-api-fetcher-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-entry-api':
    location => "https://apt.publiq.be/uitdatabank-entry-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-websocket-server':
    location => "https://apt.publiq.be/uitdatabank-websocket-server-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'uitdatabank-articlelinker':
    location => "https://apt.publiq.be/uitdatabank-articlelinker-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'publiq-versions':
    location => "https://apt.publiq.be/publiq-versions-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'publiq-prototypes':
    location => "https://apt.publiq.be/publiq-prototypes-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'publiq-infrastructure':
    location => "https://apt.publiq.be/publiq-infrastructure-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'publiq-infrastructure-legacy':
    location => "https://apt.publiq.be/publiq-infrastructure-legacy-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'publiq-appconfig':
    location => "https://apt.publiq.be/publiq-appconfig-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'publiq-jenkins':
    location => "https://apt.publiq.be/publiq-jenkins-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'museumpas-mspotm':
    location => "https://apt.publiq.be/museumpas-mspotm-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'museumpas-website':
    location => "https://apt.publiq.be/museumpas-website-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'museumpas-website-filament':
    location => "https://apt.publiq.be/museumpas-website-filament-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'museumpas-partner-website':
    location => "https://apt.publiq.be/museumpas-partner-website-${environment}",
    release  => $codename,
    repos    => 'main'
  }

  @apt::source { 'platform-api':
    location => "https://apt.publiq.be/platform-api-${environment}",
    release  => $codename,
    repos    => 'main'
  }
}
