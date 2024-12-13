class profiles::vault (
  String                     $version         = 'latest',
  Enum['running', 'stopped'] $service_status  = 'running',
  String                     $service_address = '127.0.0.1',
  Integer                    $service_port    = 8200
) inherits ::profiles {

  class { 'profiles::vault::install':
    version => $version,
    notify  => Class['profiles::vault::service']
  }

  class { 'profiles::vault::configuration':
    service_address => $service_address,
    service_port    => $service_port,
    require         => Class['profiles::vault::install'],
    notify          => Class['profiles::vault::service']
  }

  class { 'profiles::vault::service':
    service_status => $service_status
  }
}
