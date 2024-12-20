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
    service_status => $service_status
  }

  if $service_status == 'running' {
    unless $facts['vault_initialized'] {
      class { 'profiles::vault::init':
        gpg_keys => [],
        require  => Class['profiles::vault::service'],
        before   => Class['profiles::vault::seal']
      }
    }

    class { 'profiles::vault::seal':
      auto_unseal => $auto_unseal,
      require     => Class['profiles::vault::service']
    }
  }
}
