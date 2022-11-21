class profiles::uit::recommender_frontend::deployment (
  String           $config_source,
  String           $version                 = 'latest',
  Boolean          $service_manage          = true,
  String           $service_ensure          = 'running',
  Boolean          $service_enable          = true,
  Optional[String] $service_defaults_source = undef,
  Optional[String] $puppetdb_url            = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uit-recommender-frontend'

  realize Apt::Source['uit-recommender-frontend']

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
    if $service_defaults_source {
      file { 'uit-recommender-frontend-service-defaults':
        ensure => 'file',
        path   => '/etc/default/uit-recommender-frontend',
        owner  => 'root',
        group  => 'root',
        source => $service_defaults_source,
        notify => Service['uit-recommender-frontend']
      }
    }

    service { 'uit-recommender-frontend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      subscribe => [Package['uit-recommender-frontend'], File['uit-recommender-frontend-config']],
      hasstatus => true
    }
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
