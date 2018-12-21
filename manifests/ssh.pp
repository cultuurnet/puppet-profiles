class profiles::ssh {

  contain ::profiles

  sshd_config { 'PermitRootLogin':
    ensure => 'present',
    value  => 'no',
  }
}
