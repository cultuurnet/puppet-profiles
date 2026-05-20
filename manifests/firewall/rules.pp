class profiles::firewall::rules inherits ::profiles {

  @firewall { '100 accept SSH traffic':
    proto => 'tcp',
    dport => '22',
    jump  => 'accept'
  }

  @firewall { '300 accept HTTP traffic':
    proto => 'tcp',
    dport => '80',
    jump  => 'accept'
  }

  @firewall { '300 accept webcache traffic':
    proto => 'tcp',
    dport => '8080',
    jump  => 'accept'
  }

  @firewall { '300 accept HTTPS traffic':
    proto => 'tcp',
    dport => '443',
    jump  => 'accept'
  }

  @firewall { '300 accept puppetserver HTTPS traffic':
    proto => 'tcp',
    dport => '8140',
    jump  => 'accept'
  }

  @firewall { '300 accept puppetdb HTTPS traffic':
    proto => 'tcp',
    dport => '8081',
    jump  => 'accept'
  }

  @firewall { '300 accept SMTP traffic':
    proto => 'tcp',
    dport => '25',
    jump  => 'accept'
  }

  @firewall { '400 accept redis traffic':
    proto => 'tcp',
    dport => '6379',
    jump  => 'accept'
  }

  @firewall { '400 accept meilisearch traffic':
    proto => 'tcp',
    dport => '7700',
    jump  => 'accept'
  }

  @firewall { '400 accept mysql traffic':
    proto => 'tcp',
    dport => '3306',
    jump  => 'accept'
  }

  @firewall { '400 accept vault traffic':
    proto => 'tcp',
    dport => '8200',
    jump  => 'accept'
  }

  @firewall { '400 accept mongodb traffic':
    proto => 'tcp',
    dport => '27017',
    jump  => 'accept'
  }

  @firewall { '400 accept mailpit SMTP traffic':
    proto => 'tcp',
    dport => '1025',
    jump  => 'accept'
  }

  @firewall { '400 accept logstash filebeat traffic':
    proto => 'tcp',
    dport => '5000',
    jump  => 'accept'
  }

  @firewall { '500 accept carbon traffic':
    proto => 'tcp',
    dport => '2003',
    jump  => 'accept'
  }

  @firewall { '600 accept elasticsearch http traffic':
    proto => 'tcp',
    dport => '9200',
    jump  => 'accept'
  }

  @firewall { '600 accept elasticsearch cluster traffic':
    proto => 'tcp',
    dport => '9300',
    jump  => 'accept'
  }
  @firewall { '600 accept docker ephemeral ports traffic':
    proto => 'tcp',
    dport => '32768-60999',
    jump  => 'accept'
  }
}
