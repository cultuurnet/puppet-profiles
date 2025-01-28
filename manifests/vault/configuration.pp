class profiles::vault::configuration (
  Optional[String] $certname        = undef,
  String           $service_address = '127.0.0.1'
) inherits ::profiles {

  $log_level            = 'info'
  $log_rotate_max_files = 7

  realize Group['vault']
  realize User['vault']

  if $certname {
    $cert = $certname

    shellvar { 'VAULT_CACERT environment variable':
      ensure   => 'present',
      target   => '/etc/environment',
      variable => 'VAULT_CACERT',
      value    => '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
    }
  } else {
    $cert = 'tls'
  }

  shellvar { 'VAULT_ADDR environment variable':
    ensure   => 'present',
    target   => '/etc/environment',
    variable => 'VAULT_ADDR',
    value    => 'https://127.0.0.1:8200'
  }

  file { 'vault log directory':
    ensure  => 'directory',
    path    => '/opt/vault/logs',
    owner   => 'vault',
    group   => 'vault',
    require => [Group['vault'], User['vault']]
  }

  file { 'vault log file':
    ensure  => 'file',
    path    => '/opt/vault/logs/vault.log',
    owner   => 'vault',
    group   => 'vault',
    require => [Group['vault'], User['vault'], File['vault log directory']]
  }

  file { 'vault configuration':
    ensure  => 'file',
    path    => '/etc/vault.d/vault.hcl',
    owner   => 'vault',
    group   => 'vault',
    content => template('profiles/vault/vault.hcl.erb'),
    require => [Group['vault'], User['vault'], File['vault log file']]
  }
}
