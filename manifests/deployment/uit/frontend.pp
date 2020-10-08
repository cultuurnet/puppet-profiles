class profiles::deployment::uit::frontend (
  String           $config_source,
  String           $package_version     = 'latest',
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = undef
) {

  $basedir = '/var/www/uitbe-frontend/packages/app'

  contain ::profiles

  include ::profiles::deployment::uit

  realize Apt::Source['publiq-uit']
  realize Profiles::Apt::Update['publiq-uit']

  package { 'uitbe-frontend':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uit']
  }

  file { 'uitbe-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitbe-frontend']
  }

  if $service_manage {
    service { 'uitbe-frontend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uitbe-frontend'],
      hasstatus => true
    }

    File['uitbe-frontend-config'] ~> Service['uitbe-frontend']
  }

  profiles::deployment::versions { $title:
    project      => 'uit',
    packages     => 'uitbe-frontend',
    puppetdb_url => $puppetdb_url
  }
}
