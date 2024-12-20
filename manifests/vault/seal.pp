class profiles::vault::seal (
  Boolean                        $auto_unseal = false,
  Variant[String, Array[String]] $gpg_keys    = []
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

  # Initialize vault
  unless $facts['vault_initialized'] {
    exec { 'vault_init':
      command   => "/usr/bin/vault operator init -key-shares=${key_shares} -key-threshold=${key_threshold} -pgp-keys=\"/etc/vault.d/gpg_keys/vault.asc\" -tls-skip-verify -format=json > /etc/vault.d/init.json",
      user      => 'vault',
      logoutput => 'on_failure',
      require   => [User['vault'], Class['profiles::vault::gpg_key']]
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

  file { 'vault_unseal':
    ensure  => $auto_unseal ? {
                 true  => 'file',
                 false => 'absent'
               },
    path    => '/usr/local/bin/vault-unseal',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    #content => template()
  }

  # Unseal vault
  if $auto_unseal {
    exec { 'vault_unseal':
      command   => '/usr/local/bin/vault-unseal',
      unless    => '/usr/bin/vault status -tls-skip-verify',
      user      => 'vault',
      logoutput => 'on_failure',
      require   => File['vault_unseal']
    }
  }

  #set facts for gpg encrypted unseal keys for user gpg keys? -> file

  systemd::dropin_file { 'vault_override.conf':
    ensure         => $auto_unseal ? {
                        true  => 'present',
                        false => 'absent'
                      },
    unit           => 'vault.service',
    filename       => 'override.conf',
    notify_service => false,
    content        => '[Service]\nExecStartPost=/usr/local/bin/vault-unseal',
    require        => File['vault_unseal']
  }
}
