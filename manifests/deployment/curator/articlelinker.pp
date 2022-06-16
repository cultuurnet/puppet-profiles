class profiles::deployment::curator::articlelinker (
  String           $config_source,
  String           $publishers_source,
  String           $version             = 'latest',
  Optional[String] $env_defaults_source = undef,
  Boolean          $service_manage      = true,
  String           $service_ensure      = 'running',
  Boolean          $service_enable      = true,
  Optional[String] $puppetdb_url        = undef
) inherits ::profiles {

  $basedir = '/var/www/curator-articlelinker'

  realize Apt::Source['curator-articlelinker']

  package { 'curator-articlelinker':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['curator-articlelinker']
  }

  file { 'curator-articlelinker-config':
    ensure  => 'file',
    path    => "${basedir}/config.json",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['curator-articlelinker']
  }

  file { 'curator-articlelinker-publishers':
    ensure  => 'file',
    path    => "${basedir}/publishers.json",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $publishers_source,
    require => Package['curator-articlelinker']
  }

  if $service_manage {
    if $env_defaults_source {
      file { '/etc/default/curator-articlelinker':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        source => $env_defaults_source,
        notify => Service['curator-articlelinker']
      }
    }

    service { 'curator-articlelinker':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['curator-articlelinker'],
      hasstatus => true
    }

    File['curator-articlelinker-config'] ~> Service['curator-articlelinker']
    File['curator-articlelinker-publishers'] ~> Service['curator-articlelinker']
  }

  profiles::deployment::versions { $title:
    project      => 'curator',
    packages     => 'curator-articlelinker',
    puppetdb_url => $puppetdb_url
  }
}
