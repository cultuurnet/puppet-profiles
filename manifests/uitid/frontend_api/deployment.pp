class profiles::uitid::frontend_api::deployment (
  String                     $config_source,
  Integer                    $maximum_heap_size = 512,
  String                     $version           = 'latest',
  String                     $repository        = 'uitid-frontend-api',
  Enum['running', 'stopped'] $service_status    = 'running',
  Stdlib::IP::Address::V4    $service_address   = '127.0.0.1',
  Integer                    $service_port      = 4000,
  Optional[String]           $puppetdb_url      = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitid-frontend-api'

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uitid-frontend-api':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [Service['uitid-frontend-api'], Profiles::Deployment::Versions[$title]]
  }

  file { 'uitid-frontend-api-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => [Package['uitid-frontend-api'], Group['www-data'], User['www-data']],
    notify  => Service['uitid-frontend-api']
  }

  file { 'uitid-frontend-api-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uitid-frontend-api',
    owner   => 'root',
    group   => 'root',
    content => template('profiles/uitid/frontend_api/deployment/uitid-frontend-api.erb'),
    notify  => Service['uitid-frontend-api']
  }

  service { 'uitid-frontend-api':
    ensure    => $service_status,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    hasstatus => true
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
