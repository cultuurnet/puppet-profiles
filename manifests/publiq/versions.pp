class profiles::publiq::versions (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases   = [],
  Stdlib::Ipv4                   $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged     $service_port    = 3000,
  Boolean                        $deployment      = true,
  Optional[String]               $puppetdb_url    = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  unless $puppetdb_url {
    fail("Class[Profiles::Publiq::Versions] expects a value for parameter 'puppetdb_url'")
  }

  $basedir = '/var/www/publiq-versions'

  include profiles::ruby

  realize Group['www-data']
  realize User['www-data']

  profiles::puppet::puppetdb::cli { 'www-data':
    certificate_name => $servername,
    server_urls      => $puppetdb_url,
    require          => [Group['www-data'], User['www-data']]
  }

  file { 'publiq-versions-env':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    content => 'PUPPETDB_CONFIG_SOURCE=\'/var/www/.puppetlabs/client-tools/puppetdb.conf\'',
    require => [Group['www-data'], User['www-data']]
  }

  if $deployment {
    include profiles::publiq::versions::deployment

    Class['profiles::ruby'] -> Class['profiles::publiq::versions::deployment']
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination => "http://${service_address}:${service_port}/",
    aliases     => $serveraliases
  }

  # include ::profiles::publiq::versions::monitoring
  # include ::profiles::publiq::versions::metrics
  # include ::profiles::publiq::versions::backup
  # include ::profiles::publiq::versions::logging
}
