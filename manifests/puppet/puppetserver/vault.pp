class profiles::puppet::puppetserver::vault (
) inherits ::profiles {

  package { 'vault-puppetserver-gem':
    ensure   => 'installed',
    name     => 'vault',
    provider => 'puppetserver_gem',
  }

  @@profiles::vault::trusted_certificate { $trusted['certname']: }
}
