class profiles::uitpas::balie (
  Boolean                       $deployment      = true,
  Stdlib::Ipv4                  $service_address = '127.0.0.1',
  Integer                       $service_port    = 4000,
) inherits ::profiles {

  include ::profiles::nodejs

  if $deployment {
    class { 'profiles::uitpas::balie::deployment':
      service_address => $service_address,
      service_port    => $service_port
    }

    Class['profiles::nodejs'] -> Class['profiles::uitpas::balie::deployment']
  }

  # include ::profiles::uitpas::balie::monitoring
  # include ::profiles::uitpas::balie::metrics
  # include ::profiles::uitpas::balie::backup
  # include ::profiles::uitpas::balie::logging
}
