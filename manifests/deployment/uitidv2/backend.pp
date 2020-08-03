class profiles::deployment::uitidv2::backend (
  String           $config_source,
  String           $package_version     = 'latest',
  Optional[String] $env_defaults_source = undef,
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = undef
) {

  $basedir = '/var/www/uitid-backend'

  contain ::profiles

  include ::profiles::deployment::uitidv2

  realize Apt::Source['publiq-uitidv2']
  realize Profiles::Apt::Update['publiq-uitidv2']

  package { 'uitid-backend':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uitidv2']
  }

  file { 'uitid-backend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitid-backend']
  }

  if $service_manage {
    if $env_defaults_source {
      file { '/etc/default/uitid-backend':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        source => $env_defaults_source,
        notify => Service['uitid-backend']
      }
    }

    service { 'uitid-backend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uitid-backend'],
      hasstatus => true
    }

    File['uitid-backend-config'] ~> Service['uitid-backend']
  }

  profiles::deployment::versions { $title:
    project      => 'uitid',
    packages     => 'uitid-backend',
    puppetdb_url => $puppetdb_url
  }
}
