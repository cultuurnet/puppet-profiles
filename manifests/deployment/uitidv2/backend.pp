class profiles::deployment::uitidv2::backend (
  String           $config_source,
  String           $version             = 'latest',
  Optional[String] $env_defaults_source = undef,
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = undef
) inherits ::profiles {

  $basedir = '/var/www/uitid-api'

  realize Apt::Source['uitid-api']

  package { 'uitid-api':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['uitid-api']
  }

  file { 'uitid-api-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitid-api']
  }

  if $service_manage {
    if $env_defaults_source {
      file { '/etc/default/uitid-api':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        source => $env_defaults_source,
        notify => Service['uitid-api']
      }
    }

    service { 'uitid-api':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uitid-api'],
      hasstatus => true
    }

    File['uitid-api-config'] ~> Service['uitid-api']
  }

  profiles::deployment::versions { $title:
    project      => 'uitid',
    packages     => 'uitid-api',
    puppetdb_url => $puppetdb_url
  }
}
