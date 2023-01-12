class profiles::udb3::websocket_server::deployment (
  String           $config_source,
  String           $version        = 'latest',
  Boolean          $service_manage = true,
  String           $service_ensure = 'running',
  Boolean          $service_enable = true,
  Integer          $listen_port    = lookup('profiles::udb3::websocket_server::listen_port', Integer, 'first', 3000),
  Optional[String] $puppetdb_url   = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/udb3-websocket-server'

  realize Apt::Source['uitdatabank-websocket-server']

  package { 'uitdatabank-websocket-server':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['uitdatabank-websocket-server']
  }

  file { 'uitdatabank-websocket-server-config':
    ensure  => 'file',
    path    => "${basedir}/config.json",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitdatabank-websocket-server']
  }

  if $service_manage {
    file { 'uitdatabank-websocket-server-service-defaults':
      ensure  => 'file',
      path    => '/etc/default/uitdatabank-websocket-server',
      content => "PORT=${listen_port}",
      require => Package['uitdatabank-websocket-server']
    }

    service { 'uitdatabank-websocket-server':
      ensure    => $service_ensure,
      enable    => $service_enable,
      subscribe => [Package['uitdatabank-websocket-server'], File['uitdatabank-websocket-server-config'], File['uitdatabank-websocket-server-service-defaults']],
      hasstatus => true
    }
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
