class profiles::uit::frontend::deployment (
  String                     $config_source,
  String                     $version                 = 'latest',
  String                     $uitdatabank_api_url     = 'http://localhost',
  String                     $repository              = 'uit-frontend',
  Enum['running', 'stopped'] $service_status          = 'running',
  Optional[String]           $service_defaults_source = undef,
  Optional[String]           $maintenance_source      = undef,
  Optional[String]           $deployment_source       = undef,
  Optional[String]           $puppetdb_url            = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uit-frontend'

  realize Apt::Source[$repository]

  package { 'uit-frontend':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source[$repository]
  }

  file { 'uit-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/packages/app/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-frontend']
  }

  file { 'uit-frontend-migration-script':
    ensure  => 'file',
    path    => "${basedir}/migrate.sh",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    content => template('profiles/uit/frontend/migrate.sh.erb')
  }

  if $maintenance_source {
    file { 'uit-maintenance-pages':
      ensure  => 'directory',
      path    => "${basedir}/maintenance",
      recurse => true,
      source  => $maintenance_source,
      owner   => 'www-data',
      group   => 'www-data',
      require => Package['uit-frontend']
    }
  }

  if $deployment_source {
    file { 'uit-deployment-pages':
      ensure  => 'directory',
      path    => "${basedir}/deployment",
      recurse => true,
      source  => $deployment_source,
      owner   => 'www-data',
      group   => 'www-data',
      require => Package['uit-frontend']
    }
  }

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
    ensure    => $service_status,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    require   => Package['uit-frontend'],
    subscribe => File['uit-frontend-config'],
    hasstatus => true
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
