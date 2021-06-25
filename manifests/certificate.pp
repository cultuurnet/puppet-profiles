define profiles::certificate (
  $certificate_source,
  $key_source
) {

  include ::profiles

  file { "${title}.bundle.crt":
    path   => "/etc/ssl/certs/${title}.bundle.crt",
    mode   => '0644',
    source => $certificate_source
  }

  file { "${title}.key":
    path   => "/etc/ssl/private/${title}.key",
    mode   => '0644',
    source => $key_source
  }
}
