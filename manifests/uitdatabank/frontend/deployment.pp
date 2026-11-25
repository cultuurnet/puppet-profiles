class profiles::uitdatabank::frontend::deployment (
  String                        $config_source,
  Enum['instance', 'container'] $type            = 'instance',
  Stdlib::IP::Address::V4       $service_address = '127.0.0.1',
  Integer                       $service_port    = 4000,
) inherits ::profiles {

  $config_dir = '/etc/uitdatabank-frontend'
  $secrets    = lookup('vault:uitdatabank/udb3-frontend')

  case $type {
    'instance': {
      class { 'profiles::uitdatabank::frontend::deployment::instance':
        service_address => $service_address,
        service_port    => $service_port,
      }
    }
    'container': {
      class { 'profiles::uitdatabank::frontend::deployment::container':
        service_port => $service_port,
      }
    }
  }

  file { $config_dir:
    ensure => 'directory'
  }

  file { "${config_dir}/env":
    ensure  => 'file',
    content => template($config_source),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    notify  => Class["profiles::uitdatabank::frontend::deployment::${type}"]
  }
}
