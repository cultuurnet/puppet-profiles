class profiles::deployment::uitpas_be::frontend (
  String           $config_source,
  String           $package_version     = 'latest',
  Optional[String] $env_defaults_source = undef,
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = undef
) {

  $basedir = '/var/www/uitpasbe-frontend'

  contain profiles
  contain profiles::deployment::uitpas_be

  realize Apt::Source['publiq-uitpasbe']
  realize Profiles::Apt::Update['publiq-uitpasbe']

  package { 'uitpasbe-frontend':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uitpasbe']
  }

  file { 'uitpasbe-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitpasbe-frontend']
  }

  if $service_manage {
    if $env_defaults_source {
      file { '/etc/default/uitpasbe-frontend':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        source => $env_defaults_source,
        notify => Service['uitpasbe-frontend']
      }
    }

    service { 'uitpasbe-frontend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uitpasbe-frontend'],
      hasstatus => true
    }

    File['uitpasbe-frontend-config'] ~> Service['uitpasbe-frontend']
  }

  profiles::deployment::versions { $title:
    project      => 'uitpasbe',
    packages     => 'uitpasbe-frontend',
    puppetdb_url => $puppetdb_url
  }
}
