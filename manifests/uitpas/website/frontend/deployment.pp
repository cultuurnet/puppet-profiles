class profiles::uitpas::website::frontend::deployment (
  String                     $config_source,
  String                     $version           = 'latest',
  String                     $repository        = 'uitpas-website-frontend',
  Enum['running', 'stopped'] $service_status    = 'running',
  Stdlib::IP::Address::V4    $service_address   = '127.0.0.1',
  Integer                    $service_port      = 3000,
  Optional[String]           $puppetdb_url      = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitpas-website-frontend'
  $secrets = lookup('vault:uitpas/website/frontend')

  realize Apt::Source[$repository]
  realize Group['www-data']
  realize User['www-data']

  package { 'uitpas-website-frontend':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source[$repository]
  }

  file { 'uitpas-website-frontend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    content  => template($config_source),
    require => Package['uitpas-website-frontend'],
    notify  => Service['uitpas-website-frontend']
  }

  file { 'uitpas-website-frontend-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uitpas-website-frontend',
    owner   => 'root',
    group   => 'root',
    content => template('profiles/uitpas/website/frontend/deployment/uitpas-website-frontend.erb'),
    notify  => Service['uitpas-website-frontend']
  }

  service { 'uitpas-website-frontend':
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
