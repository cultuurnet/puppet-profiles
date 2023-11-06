class profiles::filebeat (
  String                     $version         = 'installed',
  Hash                       $inputs          = {},
  Hash                       $outputs         = {},
  Hash                       $setup           = {},
  Hash                       $shipper         = {},
  Hash                       $logging         = {},
  Array                      $modules         = [],
  Enum['running', 'stopped'] $service_ensure  = 'running',
  Boolean                    $service_enable  = true
) inherits ::profiles {

  realize Apt::Source['elastic-8.x']

  package { 'filebeat':
    ensure  => $version,
  }

  class { 'filebeat':
    manage_repo    => false,
    manage_package => false,
    manage_apt     => false,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
    outputs        => $outputs,
    setup          => $setup,
    shipper        => $shipper,
    logging        => $logging,
    modules        => $modules
  }

  create_resources('filebeat::input', $inputs)
}

