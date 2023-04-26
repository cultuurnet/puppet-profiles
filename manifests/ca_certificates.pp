class profiles::ca_certificates (
  Variant[String, Array[String]] $disabled_ca_certificates = []
) inherits ::profiles {

  [$disabled_ca_certificates].flatten.each |$certificate| {
    augeas { "Disable CA certificate ${certificate}":
      lens    => 'Simplelines.lns',
      incl    => '/etc/ca-certificates.conf',
      context => '/files/etc/ca-certificates.conf',
      onlyif  => "get *[.= '${certificate}'] == '${certificate}'",
      changes => "set *[.= '${certificate}'] '!${certificate}'",
      notify => Exec['Update CA certificates']
    }
  }

  exec { 'Update CA certificates':
    command     => 'update-ca-certificates',
    path        => [ '/usr/local/bin', '/usr/bin', '/usr/sbin', '/bin'],
    refreshonly => true
  }
}
