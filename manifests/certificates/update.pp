class profiles::certificates::update inherits ::profiles {

  exec { 'Update CA certificates':
    command     => 'update-ca-certificates',
    path        => [ '/usr/local/bin', '/usr/bin', '/usr/sbin', '/bin'],
    refreshonly => true
  }
}
