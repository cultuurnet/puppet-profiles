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

  @firewall { '300 accept webcache traffic':
    proto  => 'tcp',
    dport  => '8080',
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

  @firewall { '400 accept mysql traffic':
    proto  => 'tcp',
    dport  => '3306',
    action => 'accept'
  }

  @firewall { '400 accept vault traffic':
    proto  => 'tcp',
    dport  => '8200',
    action => 'accept'
  }

  @firewall { '400 accept mongodb traffic':
    proto  => 'tcp',
    dport  => '27017',
    action => 'accept'
  }

  @firewall { '400 accept mailpit SMTP traffic':
    proto  => 'tcp',
    dport  => '1025',
    action => 'accept'
  }

  @firewall { '500 accept carbon traffic':
    proto  => 'tcp',
    dport  => '2003',
    action => 'accept'
  }

  @firewall { '600 accept elasticsearch http traffic':
    proto  => 'tcp',
    dport  => '9200',
    action => 'accept'
  }

  @firewall { '600 accept elasticsearch cluster traffic':
    proto  => 'tcp',
    dport  => '9300',
    action => 'accept'
  }
  @firewall { '600 accept docker ephemeral ports traffic':
    proto  => 'tcp',
    dport  => '32768:60999',
    action => 'accept'
  }
}
