class profiles::deployment::uit::frontend (
  String           $config_source,
  String           $version                 = 'latest',
  String           $uitdatabank_api_url     = 'http://localhost',
  Boolean          $service_manage          = true,
  String           $service_ensure          = 'running',
  Boolean          $service_enable          = true,
  Optional[String] $service_defaults_source = undef,
  Optional[String] $maintenance_source      = undef,
  Optional[String] $puppetdb_url            = undef
) inherits ::profiles {

  include ::profiles::deployment::uit

  $basedir = '/var/www/uit-frontend/packages/app'

  realize Profiles::Apt::Update['publiq-uit']

  package { 'uit-frontend':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-uit']
  }

  file { 'uit-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-frontend']
  }

  file { 'uit-frontend-migration-script':
    ensure  => 'file',
    path    => "${basedir}/../../migrate.sh",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    content => template('profiles/deployment/uit/frontend/migrate.sh.erb')
  }

  if $maintenance_source {
    file { 'uit-maintenance-pages':
      ensure  => 'directory',
      path    => "${basedir}/../../maintenance",
      recurse => true,
      source  => $maintenance_source,
      owner   => 'www-data',
      group   => 'www-data',
      require => Package['uit-frontend']
    }
  }

  if $service_manage {
    if $service_defaults_source {
      file { 'uit-frontend-service-defaults':
        ensure => 'file',
        path   => '/etc/default/uit-frontend',
        owner  => 'root',
        group  => 'root',
        source => $service_defaults_source,
        notify => Service['uit-frontend']
      }
    }

    service { 'uit-frontend':
      ensure    => $service_ensure,
      enable    => $service_enable,
      require   => Package['uit-frontend'],
      subscribe => File['uit-frontend-config'],
      hasstatus => true
    }
  }

  profiles::deployment::versions { $title:
    project      => 'uit',
    packages     => 'uit-frontend',
    puppetdb_url => $puppetdb_url
  }
}
