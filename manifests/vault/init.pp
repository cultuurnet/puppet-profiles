class profiles::vault::init (
  Boolean                        $auto_unseal = false,
  Variant[String, Array[String]] $gpg_keys    = []
) inherits ::profiles {

  if (!$auto_unseal and empty($gpg_keys)) {
    fail('without auto_unseal, at least one GPG key has to be provided')
  }

  $key_threshold = 1

  if $auto_unseal {
    $full_name       = 'Vault'
    $email_address   = 'vault@publiq.be'
    $key_shares      = length([$email_address].flatten + [$gpg_keys].flatten)
    $init_key_string = '/etc/vault.d/gpg_keys/vault.asc'

    class { 'profiles::vault::gpg_key':
      full_name     => $full_name,
      email_address => $email_address,
      before        => Exec['vault_init']
    }
  } else {
    $key_shares = length([$gpg_keys].flatten)
  }

  realize Group['vault']
  realize User['vault']
  realize Package['jq']

  file { 'vault_process_init':
    ensure  => 'file',
    path    => '/usr/local/bin/vault-process-init',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/profiles/vault/vault-process-init'
  }

  exec { 'vault_init':
    command   => "/usr/bin/vault operator init -key-shares=${key_shares} -key-threshold=${key_threshold} -pgp-keys=\"${init_key_string}\" -tls-skip-verify -format=json | /usr/local/bin/vault-process-init",
    user      => 'vault',
    logoutput => 'on_failure',
    require   => [User['vault'], File['vault_process_init'], Package['jq']]
  }

  file { 'vault_initialized_external_fact':
    ensure  => 'file',
    path    => '/etc/puppetlabs/facter/facts.d/vault_initialized.txt',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => 'vault_initialized=true',
    require => Exec['vault_init']
  }
}
