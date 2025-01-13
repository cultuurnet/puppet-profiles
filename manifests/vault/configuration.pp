class profiles::vault::configuration (
  String $certname        = $facts['networking']['fqdn'],
  String $service_address = '127.0.0.1'
) inherits ::profiles {

  shellvar { 'VAULT_ADDR environment variable':
    ensure   => 'present',
    target   => '/etc/environment',
    variable => 'VAULT_ADDR',
    value    => 'https://127.0.0.1:8200'
  }

  shellvar { 'VAULT_CACERT environment variable':
    ensure   => 'present',
    target   => '/etc/environment',
    variable => 'VAULT_CACERT',
    value    => '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
  }

  class { 'profiles::vault::certificate':
    certname => $certname
  }
}
