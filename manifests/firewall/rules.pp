class profiles::firewall::rules inherits ::profiles {

  @firewall { '100 accept SSH traffic':
    proto  => 'tcp',
    dport  => '22',
    action => 'accept'
  }

  @firewall { '200 accept NRPE traffic':
    proto  => 'tcp',
    dport  => '5666',
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

  @firewall { '300 accept puppetserver HTTPS traffic':
    proto  => 'tcp',
    dport  => '8140',
    action => 'accept'
  }

  @firewall { '300 accept puppetdb HTTPS traffic':
    proto  => 'tcp',
    dport  => '8081',
    action => 'accept'
  }

  @firewall { '300 accept SMTP traffic':
    proto  => 'tcp',
    dport  => '25',
    action => 'accept'
  }

  @firewall { '400 accept redis traffic':
    proto  => 'tcp',
    dport  => '6379',
    action => 'accept'
  }

  @firewall { '400 accept meilisearch traffic':
    proto  => 'tcp',
    dport  => '7700',
    action => 'accept'
  }
}
