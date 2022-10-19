class profiles::deployment::uit::recommender_frontend (
  String           $config_source,
  String           $version                 = 'latest',
  Boolean          $service_manage          = true,
  String           $service_ensure          = 'running',
  Boolean          $service_enable          = true,
  Optional[String] $puppetdb_url            = undef
) inherits ::profiles {

  $basedir = '/var/www/uit-recommender-frontend'

  realize Apt::Source['yarn']
  realize Apt::Source['uit-recommender-frontend']

  realize Package['yarn']

  package { 'uit-recommender-frontend':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['uit-recommender-frontend']
  }

  file { 'uit-recommender-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-recommender-frontend']
  }

  if $service_manage {
    service { 'uit-recommender-frontend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => [ Package['uit-recommender-frontend'], File['uit-recommender-frontend-config'], Package['yarn'] ],
      subscribe => File['uit-recommender-frontend-config'],
      hasstatus => true
    }
  }

  profiles::deployment::versions { $title:
    project      => 'uit',
    packages     => 'uit-recommender-frontend',
    puppetdb_url => $puppetdb_url
  }
}
