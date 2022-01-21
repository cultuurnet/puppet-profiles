class profiles::certificates (
  Hash                           $certificates             = {},
  Variant[String, Array[String]] $disabled_ca_certificates = []
) inherits ::profiles {

  include ::profiles::certificates::update

  $certificates.each |$certificate, $sources| {
    @profiles::certificate { $certificate:
      * => $sources
    }
  }

  [$disabled_ca_certificates].flatten.each |$certificate| {
    augeas { "Disable CA certificate ${certificate}":
      lens    => 'Simplelines.lns',
      incl    => '/etc/ca-certificates.conf',
      context => '/files/etc/ca-certificates.conf',
      onlyif  => "get *[.= '${certificate}'] == '${certificate}'",
      changes => "set *[.= '${certificate}'] '!${certificate}'",
      notify => Class['profiles::certificates::update']
    }
  }
}
