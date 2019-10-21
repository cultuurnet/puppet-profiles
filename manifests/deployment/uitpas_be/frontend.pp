class profiles::deployment::uitpas_be::frontend (
  String           $config_source,
  Optional[String] $env_defaults_source = undef,
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = undef
) {

  $basedir = '/var/www/uitpas.be-frontend'

  contain profiles
  contain profiles::deployment::uitpas_be

  realize Apt::Source['publiq-uitpas.be']
  realize Profiles::Apt::Update['publiq-uitpas.be']

  package { 'uitpas.be-frontend':
    ensure  => 'latest',
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uitpas.be']
  }

  file { 'uitpas.be-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitpas.be-frontend']
  }

  if $service_manage {
    if $env_defaults_source {
      file { '/etc/default/uitpas.be-frontend':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        source => $env_defaults_source,
        notify => Service['uitpas.be-frontend']
      }
    }

    service { 'uitpas.be-frontend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uitpas.be-frontend'],
      hasstatus => true
    }

    File['uitpas.be-frontend-config'] ~> Service['uitpas.be-frontend']
  }

  profiles::deployment::versions { $title:
    project      => 'uitpas.be',
    packages     => 'uitpas.be-frontend',
    puppetdb_url => $puppetdb_url
  }
}
