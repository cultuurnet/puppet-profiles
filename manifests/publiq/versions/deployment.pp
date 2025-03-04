class profiles::publiq::versions::deployment (
  String                     $version         = 'latest',
  String                     $repository      = 'publiq-versions',
  Stdlib::IP::Address::V4    $service_address = lookup('profiles::publiq::versions::service_address', Stdlib::IP::Address::V4, 'first', '127.0.0.1'),
  Stdlib::Port::Unprivileged $service_port    = lookup('profiles::publiq::versions::service_port', Stdlib::Port::Unprivileged, 'first', 3000),
  Enum['running', 'stopped'] $service_status  = 'running',
  Optional[String]           $puppetdb_url    = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/publiq-versions'

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'publiq-versions':
    ensure  => $version,
    notify  => [Service['publiq-versions'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'publiq-versions-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/publiq-versions',
    owner   => 'root',
    group   => 'root',
    content => template('profiles/publiq/versions/deployment.erb'),
    notify  => Service['publiq-versions']
  }

  service { 'publiq-versions':
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
