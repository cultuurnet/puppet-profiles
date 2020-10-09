class profiles::deployment::uit::api (
  String           $config_source,
  String           $package_version     = 'latest',
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = undef
) {

  $basedir = '/var/www/uit-api/packages/graphql'

  contain ::profiles

  include ::profiles::deployment::uit

  realize Apt::Source['publiq-uit']
  realize Profiles::Apt::Update['publiq-uit']

  package { 'uit-api':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uit']
  }

  file { 'uit-api-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-api']
  }

  if $service_manage {
    service { 'uit-api':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uit-api'],
      hasstatus => true
    }

    File['uit-api-config'] ~> Service['uit-api']
  }

  profiles::deployment::versions { $title:
    project      => 'uit',
    packages     => 'uit-api',
    puppetdb_url => $puppetdb_url
  }
}
