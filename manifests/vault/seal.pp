class profiles::vault::seal (
  Boolean $auto_unseal = false
) inherits ::profiles {

  realize Group['vault']
  realize User['vault']

  file { 'vault_unseal':
    ensure => $auto_unseal ? {
                 true  => 'file',
                 false => 'absent'
               },
    path   => '/usr/local/bin/vault-unseal',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profiles/vault/vault-unseal'
  }

  if $auto_unseal {
    exec { 'vault_unseal':
      command   => '/usr/local/bin/vault-unseal /home/vault/encrypted_unseal_key',
      unless    => '/usr/bin/vault status -tls-skip-verify',
      user      => 'vault',
      logoutput => 'on_failure',
      require   => File['vault_unseal']
    }
  }

  systemd::dropin_file { 'vault_override.conf':
    ensure         => $auto_unseal ? {
                        true  => 'present',
                        false => 'absent'
                      },
    unit           => 'vault.service',
    filename       => 'override.conf',
    notify_service => false,
    content        => '[Service]\nExecStartPost=/usr/local/bin/vault-unseal /home/vault/encrypted_unseal_key',
    require        => File['vault_unseal']
  }
}
