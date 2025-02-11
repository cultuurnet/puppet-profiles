class profiles::vault::authentication (
  Optional[Integer] $lease_ttl_seconds = undef
) inherits ::profiles {

  $trusted_certs_directory = '/etc/vault.d/trusted_certs'

  realize Group['vault']
  realize User['vault']

  file { 'vault_trusted_certs':
    ensure => 'directory',
    path    => $trusted_certs_directory,
    owner   => 'vault',
    group   => 'vault',
    require => [Group['vault'], User['vault']]
  }

  exec { 'vault_cert_auth':
    command   => '/usr/bin/vault auth enable cert',
    user      => 'vault',
    unless    => '/usr/bin/vault auth list -format=json | /usr/bin/jq -e \'."cert/"\'',
    logoutput => 'on_failure',
    require   => User['vault']
  }

  if $lease_ttl_seconds {
    exec { 'vault_cert_default_lease_ttl':
      command   => "/usr/bin/vault auth tune -default-lease-ttl=${lease_ttl_seconds} cert",
      user      => 'vault',
      unless    => "/usr/bin/vault read -format=json sys/auth/cert/tune | /usr/bin/jq -e '.data | select(.default_lease_ttl==${lease_ttl_seconds})'",
      logoutput => 'on_failure',
      require   => [User['vault'], Exec['vault_cert_auth']]
    }

    exec { 'vault_cert_max_lease_ttl':
      command   => "/usr/bin/vault auth tune -max-lease-ttl=${lease_ttl_seconds} cert",
      user      => 'vault',
      unless    => "/usr/bin/vault read -format=json sys/auth/cert/tune | /usr/bin/jq -e '.data | select(.max_lease_ttl==${lease_ttl_seconds})'",
      logoutput => 'on_failure',
      require   => [User['vault'], Exec['vault_cert_auth']]
    }
  }

  if $settings::storeconfigs {
    Profiles::Vault::Trusted_certificate <<| |>> {
      trusted_certs_directory => $trusted_certs_directory,
      require                 => [File['vault_trusted_certs'], Exec['vault_cert_auth']]
    }
  }
}
