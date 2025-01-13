class profiles::vault::certificate (
  String $certname
) inherits ::profiles {

  $default_file_attributes = {
                               owner => 'vault',
                               group => 'vault',
                               require => [Group['vault'], User['vault']]
                             }

  realize Group['vault']
  realize User['vault']

  if !($certname == $facts['networking']['fqdn']) {
    puppet_certificate { $certname:
      ensure               => 'present',
      dns_alt_names        => ["DNS:${certname}", "IP:127.0.0.1"],
      waitforcert          => 60,
      renewal_grace_period => 5,
      clean                => true
    }

    Puppet_certificate[$certname] -> File['vault private key']
    Puppet_certificate[$certname] -> File['vault certificate']
  }

  file { 'vault certificate':
    ensure  => 'file',
    path    => '/opt/vault/tls/tls.crt',
    mode    => '0600',
    source  => "file:///etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    *       => $default_file_attributes
  }

  file { 'vault private key':
    ensure  => 'file',
    path    => '/opt/vault/tls/tls.key',
    mode    => '0600',
    source  => "file:///etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    *       => $default_file_attributes
  }
}
