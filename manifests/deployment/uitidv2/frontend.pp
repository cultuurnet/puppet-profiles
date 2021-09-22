class profiles::deployment::uitidv2::frontend (
  String           $config_source,
  String           $version             = 'latest',
  Optional[String] $env_defaults_source = undef,
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = undef
) inherits ::profiles {

  include ::profiles::deployment::uitidv2

  $basedir = '/var/www/uitid-frontend/app'

  realize Profiles::Apt::Update['publiq-uitidv2']

  package { 'uitid-frontend':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uitidv2']
  }

  file { 'uitid-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitid-frontend']
  }

  if $service_manage {
    if $env_defaults_source {
      file { '/etc/default/uitid-frontend':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        source => $env_defaults_source,
        notify => Service['uitid-frontend']
      }
    }

    service { 'uitid-frontend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uitid-frontend'],
      hasstatus => true
    }

    File['uitid-frontend-config'] ~> Service['uitid-frontend']
  }

  profiles::deployment::versions { $title:
    project      => 'uitid',
    packages     => 'uitid-frontend',
    puppetdb_url => $puppetdb_url
  }
}
