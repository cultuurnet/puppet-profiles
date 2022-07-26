class profiles::publiq::versions::deployment (
  String                     $version         = 'latest',
  Stdlib::Ipv4               $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged $service_port    = 3000,
  Optional[String]           $puppetdb_url    = undef
) inherits ::profiles {

  realize Apt::Source['publiq-versions']

  include profiles::publiq::versions::service

  package { 'publiq-versions':
    ensure  => $version,
    notify  => [Class['profiles::publiq::versions::service'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source['publiq-versions']
  }

  file { 'publiq-versions-env':
    ensure  => 'file',
    path    => '/var/www/publiq-versions/.env',
    owner   => 'www-data',
    group   => 'www-data',
    content => 'PUPPETDB_CONFIG_SOURCE=\'/var/www/.puppetlabs/client-tools/puppetdb.conf\'',
    notify  => Class['profiles::publiq::versions::service']
  }

  file { 'publiq-versions-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/publiq-versions',
    owner   => 'root',
    group   => 'root',
    content => template('profiles/publiq/versions/deployment.erb'),
    notify  => Class['profiles::publiq::versions::service']
  }

  profiles::deployment::versions { $title:
    project      => 'publiq',
    packages     => 'publiq-versions',
    puppetdb_url => $puppetdb_url
  }
}
