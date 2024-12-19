class profiles::vault::seal (
  Variant[String, Array[String]] $gpg_keys = []
) inherits ::profiles {

  $full_name     = 'Vault'
  $email_address = 'vault@publiq.be'
  $key_shares    = length([$email_address].flatten + [$gpg_keys].flatten)
  $key_threshold = 1

  realize Group['vault']
  realize User['vault']

  class { 'profiles::vault::gpg_key':
    full_name     => $full_name,
    email_address => $email_address
  }

  #initialize vault (gpg) -> exec, only if not initialized
  unless $facts['vault_initialized'] {
    exec { 'vault_init':
      command   => "/usr/bin/vault operator init -key-shares=${key_shares} -key-threshold=${key_threshold} -pgp-keys=\"/etc/vault.d/gpg_keys/vault.asc\" -format=json -tls-skip-verify",
      user      => 'vault',
      logoutput => 'on_failure',
      require   => [User['vault'], Class['profiles::vault::gpg_key']]
    }

    #set vault_initialized fact? -> file
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

  #unseal vault -> exec, only if sealed
  #set facts for gpg encrypted unseal keys for user gpg keys? -> file
  #if auto_unseal present -> provide override.conf
}
