class profiles::puppet::puppetdb (
  String                     $version           = 'installed',
  Optional[String]           $certname          = $facts['networking']['fqdn'],
  Optional[String]           $initial_heap_size = undef,
  Optional[String]           $maximum_heap_size = undef,
  Enum['running', 'stopped'] $service_status    = 'running'

) inherits ::profiles {

  $initial_heap_size_arg = $initial_heap_size ? { undef => {}, default => { '-Xms' => $initial_heap_size } }
  $maximum_heap_size_arg = $maximum_heap_size ? { undef => {}, default => { '-Xmx' => $maximum_heap_size } }

  $java_args = {} + $initial_heap_size_arg + $maximum_heap_size_arg

  include profiles::firewall::rules

  realize Group['postgres']
  realize User['postgres']
  realize Group['puppetdb']
  realize User['puppetdb']
  realize Apt::Source['puppet']

  realize Firewall['300 accept puppetdb HTTPS traffic']

  include profiles::java

  class { 'profiles::puppet::puppetdb::certificate':
    certname => $certname,
    notify   => Class['puppetdb::server']
  }

  class { 'puppetdb::globals':
    version => $version
  }

  class { 'puppetdb::database::postgresql':
    manage_package_repo => false,
    postgres_version    => '12',
    listen_addresses    => '127.0.0.1',
    require             => [Group['postgres'], User['postgres'], Class['puppetdb::globals']]
  }

  class { 'puppetdb::server':
    database_host           => '127.0.0.1',
    manage_firewall         => false,
    puppetdb_service_status => $service_status,
    java_args               => $java_args,
    ssl_deploy_certs        => false,
    ssl_set_cert_paths      => true,
    require                 => [Group['puppetdb'], User['puppetdb'], Apt::Source['puppet'], Class['profiles::java'], Class['puppetdb::globals'], Class['puppetdb::database::postgresql']]
  }
}
