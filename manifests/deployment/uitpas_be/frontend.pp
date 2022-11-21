class profiles::deployment::uitpas_be::frontend (
  String           $config_source,
  String           $version             = 'latest',
  Optional[String] $env_defaults_source = undef,
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitpas-website-frontend'

  realize Apt::Source['uitpas-website-frontend']

  package { 'uitpas-website-frontend':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['uitpas-website-frontend']
  }

  file { 'uitpas-website-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitpas-website-frontend']
  }

  if $service_manage {
    if $env_defaults_source {
      file { '/etc/default/uitpas-website-frontend':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        source => $env_defaults_source,
        notify => Service['uitpas-website-frontend']
      }
    }

    service { 'uitpas-website-frontend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uitpas-website-frontend'],
      hasstatus => true
    }

    File['uitpas-website-frontend-config'] ~> Service['uitpas-website-frontend']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
