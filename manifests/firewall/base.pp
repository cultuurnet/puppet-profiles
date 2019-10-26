class profiles::firewall::base {

  contain ::profiles::firewall

  firewall { '000 accept all icmp traffic':
    proto  => 'icmp',
    action => 'accept'
  }

  firewall { '001 accept all traffic to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept'
  }

  firewall { '002 reject local traffic not on loopback interface':
    proto       => 'all',
    iniface     => '! lo',
    destination => '127.0.0.0/8',
    action      => 'reject'
  }

  firewall { '003 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept'
  }

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef
  }
}
