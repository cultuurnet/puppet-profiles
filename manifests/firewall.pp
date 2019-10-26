class profiles::firewall {

  @firewall { '300 accept smtp traffic':
    proto  => 'tcp',
    dport  => '25',
    action => 'accept'
  }

  @firewall { '100 accept ssh traffic':
    proto  => 'tcp',
    dport  => '22',
    action => 'accept'
  }
}
