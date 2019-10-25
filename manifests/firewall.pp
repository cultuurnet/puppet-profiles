class profiles::firewall {

  contain ::profiles

  contain ::firewall

  resources { 'firewall':
    purge => true
  }
}
