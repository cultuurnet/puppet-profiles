class profiles::vault (
  String                     $version         = 'latest',
  Boolean                    $auto_unseal     = false,
  Enum['running', 'stopped'] $service_status  = 'running',
  String                     $service_address = '127.0.0.1'
) inherits ::profiles {

  include ::profiles::firewall::rules

  if !($service_address == '127.0.0.1') {
    realize Firewall['400 accept vault traffic']
  }

  class { 'profiles::vault::install':
    version => $version,
    notify  => Class['profiles::vault::service']
  }

  class { 'profiles::vault::configuration':
    auto_unseal     => $auto_unseal,
    service_address => $service_address,
    require         => Class['profiles::vault::install'],
    notify          => Class['profiles::vault::service']
  }

  class { 'profiles::vault::service':
    auto_unseal    => $auto_unseal,
    service_status => $service_status
  }
}
