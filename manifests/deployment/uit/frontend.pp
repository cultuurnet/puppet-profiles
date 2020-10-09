class profiles::deployment::uit::frontend (
  String           $config_source,
  String           $package_version     = 'latest',
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = undef
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
    service { 'uit-frontend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uit-frontend'],
      hasstatus => true
    }

    File['uit-frontend-config'] ~> Service['uit-frontend']
  }

  profiles::deployment::versions { $title:
    project      => 'uit',
    packages     => 'uit-frontend',
    puppetdb_url => $puppetdb_url
  }
}
