class profiles::uitdatabank::websocket_server::deployment (
  String                     $config_source,
  String                     $version         = 'latest',
  String                     $repository      = 'uitdatabank-websocket-server',
  Enum['running', 'stopped'] $service_status  = 'running',
  Stdlib::IP::Address::V4    $service_address = '127.0.0.1',
  Integer                    $service_port    = 3000,
  Optional[String] $puppetdb_url              = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/udb3-websocket-server'

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uitdatabank-websocket-server':
    ensure  => $version,
    require => [Apt::Source[$repository], Group['www-data'], User['www-data']],
    notify  => [Service['uitdatabank-websocket-server'], Profiles::Deployment::Versions[$title]]
  }

  file { 'uitdatabank-websocket-server-config':
    ensure  => 'file',
    path    => "${basedir}/config.json",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => [Package['uitdatabank-websocket-server'], Group['www-data'], User['www-data']],
    notify  => Service['uitdatabank-websocket-server']
  }

  file { 'uitdatabank-websocket-server-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uitdatabank-websocket-server',
    content => "HOST=${service_address}\nPORT=${service_port}",
    require => Package['uitdatabank-websocket-server'],
    notify  => Service['uitdatabank-websocket-server']
  }

  service { 'uitdatabank-websocket-server':
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
