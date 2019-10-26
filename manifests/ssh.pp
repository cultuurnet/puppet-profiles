class profiles::ssh {

  contain ::profiles

  include ::profiles::firewall

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

  realize Firewall['100 accept ssh traffic']
}
