class profiles::firewall {

  @firewall { '300 accept smtp traffic':
    proto  => 'tcp',
    dport  => '25',
    action => 'accept'
  }
}
