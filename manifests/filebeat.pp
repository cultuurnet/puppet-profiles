class profiles::filebeat (
  String                     $version        = 'installed',
  Hash                       $inputs         = {},
  Hash                       $outputs        = {},
  Hash                       $setup          = {},
  Hash                       $shipper        = {},
  Hash                       $logging        = {},
  Array                      $modules        = [],
  Enum['running', 'stopped'] $service_status = 'running'
) inherits ::profiles {

  realize Apt::Source['elastic-8.x']

  package { 'filebeat':
    ensure  => $version,
  }

  class { 'filebeat':
    manage_repo    => false,
    manage_package => false,
    manage_apt     => false,
    outputs        => $outputs,
    setup          => $setup,
    shipper        => $shipper,
    logging        => $logging,
    modules        => $modules,
    service_ensure => $service_status,
    service_enable => $service_status ? {
                        'running' => true,
                        'stopped' => false
                      }
  }

  $inputs.each |$name, $attributes| {
    filebeat::input { $name:
      * => $attributes
    }
  }
}

