class profiles::deployment::uit::frontend (
  String           $config_source,
  String           $package_version         = 'latest',
  Boolean          $service_manage          = true,
  String           $service_ensure          = 'running',
  Boolean          $service_enable          = true,
  Optional[String] $service_defaults_source = undef,
  Optional[String] $puppetdb_url            = undef
) {

  $basedir = '/var/www/uit-frontend/packages/app'

  contain ::profiles

  include ::profiles::deployment::uit

  realize Apt::Source['publiq-uit']
  realize Profiles::Apt::Update['publiq-uit']

  package { 'uit-frontend':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uit']
  }

  file { 'uit-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-frontend']
  }

  if $service_manage {
    if $service_defaults_source {
      file { 'uit-frontend-service-defaults':
        ensure => 'file',
        path   => '/etc/default/uit-frontend',
        owner  => 'root',
        group  => 'root',
        source => $service_defaults_source,
        notify => Service['uit-frontend']
      }
    }

    service { 'uit-frontend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uit-frontend'],
      subscribe => File['uit-frontend-config'],
      hasstatus => true
    }
  }

  profiles::deployment::versions { $title:
    project      => 'uit',
    packages     => 'uit-frontend',
    puppetdb_url => $puppetdb_url
  }
}
