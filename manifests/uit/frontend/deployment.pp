class profiles::uit::frontend::deployment (
  String                     $config_source,
  Integer                    $maximum_heap_size = 512,
  String                     $version           = 'latest',
  String                     $repository        = 'uit-frontend',
  Enum['running', 'stopped'] $service_status    = 'running',
  Stdlib::Ipv4               $service_address   = lookup('profiles::uit::frontend::service_address', Stdlib::Ipv4, 'first', '127.0.0.1'),
  Integer                    $service_port      = lookup('profiles::uit::frontend::service_port', Integer, 'first', 3000),
  Optional[String]           $puppetdb_url      = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
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

  file { 'uit-frontend-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uit-frontend',
    owner   => 'root',
    group   => 'root',
    content => template('profiles/uit/frontend/deployment/uit-frontend.erb'),
    notify  => Service['uit-frontend']
  }

  service { 'uit-frontend':
    ensure    => $service_status,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    subscribe => [Package['uit-frontend'], File['uit-frontend-config']],
    hasstatus => true
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
