class profiles::uitpas::api::fidus (
  String                         $fidus_sftp_path,
  String                         $fidus_sftp_key,
  String                         $fidus_soap_path,
  String                         $fidus_soap_keystore,
  String                         $fidus_soap_cert_password,
  String                         $fidus_soap_key_password,
  String                         $fidus_soap_alias
) inherits profiles {
  include openssl

  $secrets = lookup('vault:uitpas/api')

  $fidus_soap_keystorepath = "${fidus_soap_path}/${fidus_soap_keystore}"
  $fidus_sftp_keypath  = "${fidus_sftp_path}/${fidus_sftp_key}"

  file { $fidus_sftp_path:
    ensure => 'directory',
    owner  => 'glassfish',
    group  => 'glassfish',
    mode   => '0755',
  }
  file { $fidus_sftp_keypath:
    ensure  => 'file',
    content => base64('decode', $secrets["fidus-sftp-key"]),
    owner   => 'glassfish',
    group   => 'glassfish',
    mode    => '0600',
    require => File[$fidus_sftp_path],
  }
  file { $fidus_soap_path:
    ensure => 'directory',
    owner  => 'glassfish',
    group  => 'glassfish',
    mode   => '0755',
  }
  file { "${fidus_soap_path}/fidus-soap-cert.crt":
    ensure  => 'file',
    content => base64('decode', $secrets["fidus-soap-crt"]),
    owner   => 'glassfish',
    group   => 'glassfish',
    mode    => '0644',
    require => File[$fidus_soap_path],
    notify  => Openssl::Export::Pkcs12[$fidus_soap_alias],
  }
  file { "${fidus_soap_path}/fidus-soap-key.pem":
    ensure  => 'file',
    content => base64('decode', $secrets["fidus-soap-key"]),
    owner   => 'glassfish',
    group   => 'glassfish',
    mode    => '0600',
    require => File[$fidus_soap_path],
    notify  => Openssl::Export::Pkcs12[$fidus_soap_alias],
  }
  openssl::export::pkcs12 { $fidus_soap_alias:
    ensure   => 'present',
    basedir  => $fidus_soap_path,
    pkey     => "${fidus_soap_path}/fidus-soap-key.pem",
    cert     => "${fidus_soap_path}/fidus-soap-cert.crt",
    out_pass => $fidus_soap_cert_password,
    require  => [File["${fidus_soap_path}/fidus-soap-cert.crt"], File["${fidus_soap_path}/fidus-soap-key.pem"]],
  }
  -> exec { "chown_${fidus_soap_alias}":
    command => "/bin/chown glassfish:glassfish ${fidus_soap_keystorepath}",
    onlyif  => "/usr/bin/test -f ${fidus_soap_keystorepath}",
  }
}
