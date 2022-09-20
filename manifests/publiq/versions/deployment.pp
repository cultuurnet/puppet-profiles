class profiles::publiq::versions::deployment (
  String                     $version         = 'latest',
  Stdlib::Ipv4               $service_address = lookup('profiles::publiq::versions::service_address', Stdlib::Ipv4, 'first', '127.0.0.1'),
  Stdlib::Port::Unprivileged $service_port    = lookup('profiles::publiq::versions::service_port', Stdlib::Port::Unprivileged, 'first', 3000),
  Optional[String]           $certificate     = undef,
  Optional[String]           $private_key     = undef,
  Optional[String]           $puppetdb_url    = undef
) inherits ::profiles {

  realize Apt::Source['publiq-versions']
  realize Group['www-data']
  realize User['www-data']

  package { 'publiq-versions':
    ensure  => $version,
    notify  => [Service['publiq-versions'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source['publiq-versions']
  }

  if ($certificate and $private_key and $puppetdb_url) {
    file { 'publiq-versions-env':
      ensure  => 'file',
      path    => '/var/www/publiq-versions/.env',
      owner   => 'www-data',
      group   => 'www-data',
      content => 'PUPPETDB_CONFIG_SOURCE=\'/var/www/.puppetlabs/client-tools/puppetdb.conf\'',
      notify  => Service['publiq-versions']
    }

    profiles::puppetdb::cli::config { 'www-data':
      server_urls => $puppetdb_url,
      certificate => $certificate,
      private_key => $private_key,
      notify      => Service['publiq-versions']
    }
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
    ensure    => 'running',
    hasstatus => true,
    enable    => true
  }

  profiles::deployment::versions { $title:
    project      => 'publiq',
    packages     => 'publiq-versions',
    puppetdb_url => $puppetdb_url
  }
}
