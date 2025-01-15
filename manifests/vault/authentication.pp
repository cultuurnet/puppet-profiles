class profiles::vault::authentication (
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
    onlyif    => '/usr/bin/test -z "$(/usr/bin/vault auth list -format=json | /usr/bin/jq \'.[] | select(.type == "cert")\')"',
    logoutput => 'on_failure',
    require   => User['vault']
  }

  if $settings::storeconfigs {
    Profiles::Vault::Trusted_certificate <<| |>> {
      trusted_certs_directory => $trusted_certs_directory,
      require                 => [File['vault_trusted_certs'], Exec['vault_cert_auth']]
    }
  }
}
