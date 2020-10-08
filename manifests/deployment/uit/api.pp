class profiles::deployment::uit::api (
  String           $config_source,
  String           $package_version     = 'latest',
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = undef
) {

  $basedir = '/var/www/uitbe-api/packages/graphql'

  contain ::profiles

  include ::profiles::deployment::uit

  realize Apt::Source['publiq-uit']
  realize Profiles::Apt::Update['publiq-uit']

  package { 'uitbe-api':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uit']
  }

  file { 'uitbe-api-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitbe-api']
  }

  if $service_manage {
    service { 'uitbe-api':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uitbe-api'],
      hasstatus => true
    }

    File['uitbe-api-config'] ~> Service['uitbe-api']
  }

  profiles::deployment::versions { $title:
    project      => 'uit',
    packages     => 'uitbe-api',
    puppetdb_url => $puppetdb_url
  }
}
