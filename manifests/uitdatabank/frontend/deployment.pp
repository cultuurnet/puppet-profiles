class profiles::uitdatabank::frontend::deployment (
  String                     $config_source,
  String                     $version         = 'latest',
  String                     $repository      = 'uitdatabank-frontend',
  Enum['running', 'stopped'] $service_status  = 'running',
  Stdlib::IP::Address::V4    $service_address = '127.0.0.1',
  Integer                    $service_port    = 4000,
  Optional[String]           $puppetdb_url    = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/udb3-frontend'

  realize Apt::Source[$repository]

  package { 'uitdatabank-frontend':
    ensure  => $version,
    notify  => [Service['uitdatabank-frontend'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uitdatabank-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitdatabank-frontend'],
    notify  => Service['uitdatabank-frontend']
  }

  file { 'uitdatabank-frontend-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uitdatabank-frontend',
    owner   => 'root',
    group   => 'root',
    content => "NEXT_HOST=${service_address}\nNEXT_PORT=${service_port}\nNEXT_TELEMETRY_DISABLED=1",
    require => Package['uitdatabank-frontend'],
    notify  => Service['uitdatabank-frontend']
  }

  service { 'uitdatabank-frontend':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 }
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
