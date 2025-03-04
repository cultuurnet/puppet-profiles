class profiles::uitpas::cid_web::deployment (
  String                     $config_source,
  String                     $version         = 'latest',
  String                     $repository      = 'uitpas-cid-web',
  Enum['running', 'stopped'] $service_status  = 'running',
  Stdlib::IP::Address::V4    $service_address = '127.0.0.1',
  Integer                    $service_port    = 4000,
  Optional[String]           $puppetdb_url    = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uitpas-cid-web'

  realize Apt::Source[$repository]

  package { 'uitpas-cid-web':
    ensure  => $version,
    notify  => [Service['uitpas-cid-web'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uitpas-cid-web-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uitpas-cid-web'],
    notify  => Service['uitpas-cid-web']
  }

  file { 'uitpas-cid-web-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/uitpas-cid-web',
    owner   => 'root',
    group   => 'root',
    content => "",
    require => Package['uitpas-cid-web'],
    notify  => Service['uitpas-cid-web']
  }

  service { 'uitpas-cid-web':
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
