class profiles::uitdatabank::articlelinker::deployment (
  String                     $config_source,
  String                     $version         = 'latest',
  String                     $repository      = 'uitdatabank-articlelinker',
  Enum['running', 'stopped'] $service_status  = 'running',
  Stdlib::IP::Address::V4    $service_address = '127.0.0.1',
  Integer                    $service_port    = 5000,
  Optional[String]           $puppetdb_url    = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uit-articlelinker'
  $secrets = lookup('vault:uitdatabank/uit-articlelinker')

  realize Apt::Source[$repository]

  package { 'uitdatabank-articlelinker':
    ensure  => $version,
    notify  => [Service['uitdatabank-articlelinker'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uitdatabank-articlelinker-config':
    ensure  => 'file',
    path    => "${basedir}/config.json",
    owner   => 'www-data',
    group   => 'www-data',
    content => template($config_source),
    require => Package['uitdatabank-articlelinker'],
    notify  => Service['uitdatabank-articlelinker']
  }

  file { 'uitdatabank-articlelinker-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uitdatabank-articlelinker',
    owner   => 'root',
    group   => 'root',
    content => "HOST=${service_address}\nPORT=${service_port}",
    require => Package['uitdatabank-articlelinker'],
    notify  => Service['uitdatabank-articlelinker']
  }

  service { 'uitdatabank-articlelinker':
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
