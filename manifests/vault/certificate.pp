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

  puppet_certificate { $certname:
    ensure               => 'present',
    dns_alt_names        => ["DNS:${certname}", "IP:127.0.0.1"],
    waitforcert          => 60,
    renewal_grace_period => 5,
    clean                => true,
    before               => File['vault private key'],
    notify               => Exec['vault certificate']
  }

  exec { 'vault certificate':
    command   => "/usr/bin/cat /etc/puppetlabs/puppet/ssl/certs/${certname}.pem /etc/puppetlabs/puppet/ssl/certs/ca.pem > /opt/vault/tls/${certname}.crt",
    user      => 'vault',
    creates   => "/opt/vault/tls/${certname}.crt",
    logoutput => 'on_failure',
    require   => User['vault']
  }

  file { 'vault private key':
    ensure  => 'file',
    path    => "/opt/vault/tls/${certname}.key",
    mode    => '0600',
    source  => "file:///etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    *       => $default_file_attributes
  }
}
