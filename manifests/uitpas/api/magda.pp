class profiles::uitpas::api::magda (
  String                         $magda_sftp_path,
  String                         $magda_sftp_cert,
  String                         $magda_sftp_key,
  String                         $magda_soap_path,
  String                         $magda_soap_keystore,
  String                         $magda_soap_truststore,
  String                         $magda_soap_cert_password,
  String                         $magda_soap_key_password,
  String                         $magda_soap_alias
) inherits profiles {
  include openssl

  $secrets = lookup('vault:uitpas/api')

  $magda_sftp_certpath = "${magda_sftp_path}/${magda_sftp_cert}"
  $magda_sftp_keypath  = "${magda_sftp_path}/${magda_sftp_key}"
  $magda_soap_keystorepath = "${magda_soap_path}/${magda_soap_keystore}"
  $magda_soap_truststorepath  = "${magda_soap_path}/${magda_soap_truststore}"

  file { $magda_soap_path:
    ensure => 'directory',
    owner  => 'glassfish',
    group  => 'glassfish',
    mode   => '0755',
  }
  file { $magda_sftp_path:
    ensure => 'directory',
    owner  => 'glassfish',
    group  => 'glassfish',
    mode   => '0755',
  }
  file { $magda_sftp_certpath:
    ensure  => 'file',
    content => $secrets["magda-sftp-crt"],
    owner   => 'glassfish',
    group   => 'glassfish',
    mode    => '0644',
    require => File[$magda_sftp_path],
  }
  file { $magda_sftp_keypath:
    ensure  => 'file',
    content => $secrets["magda-sftp-key"],
    owner   => 'glassfish',
    group   => 'glassfish',
    mode    => '0600',
    require => File[$magda_sftp_path],
  }
  file { "${magda_soap_path}/magda-soap-cert.crt":
    ensure  => 'file',
    content => $secrets["magda-soap-crt"],
    owner   => 'glassfish',
    group   => 'glassfish',
    mode    => '0644',
    require => File[$magda_soap_path],
        notify  => Openssl::Export::Pkcs12[$magda_soap_alias],

  }
  file { "${magda_soap_path}/magda-soap-key.pem":
    ensure  => 'file',
    content => $secrets["magda-soap-key"],
    owner   => 'glassfish',
    group   => 'glassfish',
    mode    => '0600',
    require => File[$magda_soap_path],
    notify  => Openssl::Export::Pkcs12[$magda_soap_alias],
  }
  openssl::export::pkcs12 { $magda_soap_alias:
    ensure   => 'present',
    basedir  => $magda_soap_path,
    pkey     => '/tmp/magda-soap-key.pem',
    cert     => '/tmp/magda-soap-cert.crt',
    in_pass  => $magda_soap_key_password,
    out_pass => $magda_soap_cert_password,
    require  => [File["${magda_soap_path}/magda-soap-cert.crt"], File["${magda_soap_path}/magda-soap-key.pem"]],
  }
}
