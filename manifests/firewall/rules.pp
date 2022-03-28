class profiles::firewall::rules inherits ::profiles {

  @firewall { '100 accept SSH traffic':
    proto  => 'tcp',
    dport  => '22',
    action => 'accept'
  }

  @firewall { '300 accept HTTP traffic':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept'
  }

  @firewall { '300 accept HTTPS traffic':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept'
  }

  @firewall { '300 accept SMTP traffic':
    proto  => 'tcp',
    dport  => '25',
    action => 'accept'
  }

}
