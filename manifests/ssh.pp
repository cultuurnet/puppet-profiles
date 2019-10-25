class profiles::ssh {

  contain ::profiles

  Sshd_config {
    notify => Service['ssh']
  }

  sshd_config { 'PermitRootLogin':
    ensure => 'present',
    value  => 'no'
  }

  service { 'ssh':
    ensure => 'running',
    enable => true
  }

  firewall { '100 accept SSH traffic':
    proto  => 'tcp',
    dport  => '22',
    action => 'accept'
  }
}
