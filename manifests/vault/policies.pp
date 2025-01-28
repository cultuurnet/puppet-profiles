class profiles::vault::policies (
) inherits ::profiles {

  $policies_directory = '/etc/vault.d/policies'

  realize Group['vault']
  realize User['vault']

  file { 'vault_policies':
    ensure => 'directory',
    path    => $policies_directory,
    owner   => 'vault',
    group   => 'vault',
    require => [Group['vault'], User['vault']]
  }

  profiles::vault::policy { 'puppet_certificate':
    policy             => 'path "puppet/*" { capabilities = ["read"] }',
    policies_directory => $policies_directory,
    require            => File['vault_policies']
  }
}
