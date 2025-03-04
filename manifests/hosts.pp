class profiles::hosts inherits ::profiles {

  host { $trusted['certname']:
    ensure       => 'present',
    host_aliases => [$trusted['hostname'], 'localhost'],
    ip           => '127.0.0.1',
    target       => '/etc/hosts'
  }

  host { $trusted['hostname']:
    ensure => 'absent',
    ip     => '127.0.0.1',
    target => '/etc/hosts'
  }
}
