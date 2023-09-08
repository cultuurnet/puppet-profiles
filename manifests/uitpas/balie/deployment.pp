class profiles::uitpas::balie::deployment (
  String                     $config_source,
  Integer                    $maximum_heap_size = 512,
  String                     $version           = 'latest',
  String                     $repository        = 'uitpas-balie',
  Enum['running', 'stopped'] $service_status    = 'running',
  Stdlib::Ipv4               $service_address   = '127.0.0.1',
  Integer                    $service_port      = 4000,
  Optional[String]           $puppetdb_url      = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitpas-balie'

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uitpas-balie':
    ensure  => $version,
    notify  => [Profiles::Deployment::Versions[$title], Service['uitpas-balie']],
    require => Apt::Source[$repository]
  }

  file { 'uitpas-balie-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => [Package['uitpas-balie'], Group['www-data'], User['www-data']],
    notify  => Service['uitpas-balie']
  }

  file { 'uitpas-balie-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uitpas-balie',
    owner   => 'root',
    group   => 'root',
    content => template('profiles/uitpas/balie/deployment/uitpas-balie.erb'),
    notify  => Service['uitpas-balie']
  }

  service { 'uitpas-balie':
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
