class profiles::uitdatabank::frontend::deployment (
  String                  $config_source,
  Stdlib::IP::Address::V4 $service_address = '127.0.0.1',
  Integer                 $service_port    = 4000,
) inherits ::profiles {

  $type = assert_type(Enum['instance', 'container'], $profiles::uitdatabank::frontend::type)

  case $type {
    'instance': {
      class { 'profiles::uitdatabank::frontend::deployment::instance':
        config_source   => $config_source,
        service_address => $service_address,
        service_port    => $service_port,
      }
    }
    'container': {
      class { 'profiles::uitdatabank::frontend::deployment::container':
        config_source   => $config_source,
        service_address => $service_address,
        service_port    => $service_port,
      }
    }
  }
}
