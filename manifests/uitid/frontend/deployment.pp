class profiles::uitid::frontend::deployment (
  String                     $config_source,
  Integer                    $maximum_heap_size = 512,
  String                     $version           = 'latest',
  String                     $repository        = 'uitid-frontend',
  Enum['running', 'stopped'] $service_status    = 'running',
  Stdlib::Ipv4               $service_address   = '127.0.0.1',
  Integer                    $service_port      = 3000,
  Optional[String]           $puppetdb_url      = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitid-frontend/app'

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uitid-frontend':
    ensure  => $version,
    notify  => [Profiles::Deployment::Versions[$title], Service['uitid-frontend']],
    require => Apt::Source[$repository]
  }

  file { 'uitid-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => [Group['www-data'], User['www-data'], Package['uitid-frontend']],
    notify  => Service['uitid-frontend']
  }

  file { 'uitid-frontend-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uitid-frontend',
    owner   => 'root',
    group   => 'root',
    content => template('profiles/uitid/frontend/deployment/uitid-frontend.erb'),
    notify  => Service['uitid-frontend']
  }

  service { 'uitid-frontend':
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
