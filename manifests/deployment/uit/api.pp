class profiles::deployment::uit::api (
  String           $config_source,
  String           $package_version         = 'latest',
  Boolean          $service_manage          = true,
  String           $service_ensure          = 'running',
  Boolean          $service_enable          = true,
  Optional[String] $service_defaults_source = undef,
  Optional[String] $puppetdb_url            = undef
) {

  $basedir = '/var/www/uit-api'

  contain ::profiles

  include ::profiles::repositories
  include ::profiles::deployment::uit

  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['cultuurnet-tools']

  realize Apt::Source['publiq-uit']
  realize Profiles::Apt::Update['publiq-uit']

  realize Package['yarn']

  package { 'uit-api':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uit']
  }

  file { 'uit-api-config':
    ensure  => 'file',
    path    => "${basedir}/packages/graphql/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-api']
  }

  exec { 'uit-api_db_schema_update':
    command     => 'yarn graphql typeorm migration:run',
    cwd         => $basedir,
    user        => 'www-data',
    group       => 'www-data',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    refreshonly => true,
    subscribe   => [ Package['uit-api'], File['uit-api-config']],
    require     => Package['yarn']
  }


  if $service_manage {
    if $service_defaults_source {
      file { 'uit-api-service-defaults':
        ensure => 'file',
        path   => '/etc/default/uit-api',
        owner  => 'root',
        group  => 'root',
        source => $service_defaults_source,
        notify => Service['uit-api']
      }
    }

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
