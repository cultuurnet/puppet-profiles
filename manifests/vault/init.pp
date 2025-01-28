class profiles::vault::init (
  Boolean                   $auto_unseal   = false,
  Integer[1]                $key_threshold = 1,
  Variant[Hash,Array[Hash]] $gpg_keys      = []
) inherits ::profiles {

  $gpg_keys_directory = '/etc/vault.d/gpg_keys'
  $gpg_keys_exports   = [$gpg_keys].flatten.map |$gpg_key| { "${gpg_keys_directory}/${gpg_key['fingerprint']}.asc" }
  $gpg_keys_owners    = $auto_unseal ? {
                          true  => join(["Vault"] + [$gpg_keys].flatten.map |$gpg_key| { $gpg_key['owner'] }, ','),
                          false => join([$gpg_keys].flatten.map |$gpg_key| { $gpg_key['owner'] }, ',')
                        }
  $init_key_string    = $auto_unseal ? {
                          true  => join(["${gpg_keys_directory}/vault.asc"] + $gpg_keys_exports, ','),
                          false => join($gpg_keys_exports, ',')
                        }
  $key_shares         = $auto_unseal ? {
                          true  => 1 + length([$gpg_keys].flatten),
                          false => length([$gpg_keys].flatten)
                        }

  realize Group['vault']
  realize User['vault']
  realize Package['jq']
  realize File['/etc/puppetlabs']
  realize File['/etc/puppetlabs/facter']
  realize File['/etc/puppetlabs/facter/facts.d']

  file { 'vault_gpg_keys':
    ensure => 'directory',
    path    => $gpg_keys_directory,
    owner   => 'vault',
    group   => 'vault',
    require => [Group['vault'], User['vault']]
  }

  if $auto_unseal {
    class { 'profiles::vault::gpg_key':
      full_name          => 'Vault',
      email_address      => 'vault@publiq.be',
      gpg_keys_directory => $gpg_keys_directory,
      before             => Exec['vault_init'],
      require            => File['vault_gpg_keys']
    }

    exec { 'vault_auto_unseal_key':
      command   => '/usr/bin/jq -r \'.unseal_keys_b64[0]\' /home/vault/vault_init_output.json > /home/vault/encrypted_unseal_key',
      user      => 'vault',
      creates   => '/home/vault/encrypted_unseal_key',
      logoutput => 'on_failure',
      require   => [Exec['vault_init'], Package['jq']]
    }
  }

  [$gpg_keys].flatten.each |$gpg_key| {
    gnupg_key { $gpg_key['fingerprint']:
      ensure      => 'present',
      key_id      => $gpg_key['fingerprint'][-16,16],
      user        => 'vault',
      key_content => $gpg_key['key'],
      key_type    => 'public',
      require     => User['vault']
    }

    exec { "export_gpg_key ${gpg_key['fingerprint']}":
      command   => "/usr/bin/gpg --export ${gpg_key['fingerprint']} | /usr/bin/base64 > ${gpg_keys_directory}/${gpg_key['fingerprint']}.asc",
      user      => 'vault',
      creates   => "${gpg_keys_directory}/${gpg_key['fingerprint']}.asc",
      logoutput => 'on_failure',
      require   => [File['vault_gpg_keys'], Gnupg_key[$gpg_key['fingerprint']]],
      before    => Exec['vault_init']
    }
  }

  file { 'vault_process_init_output':
    ensure  => 'file',
    path    => '/usr/local/bin/vault-process-init-output',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/profiles/vault/vault-process-init-output'
  }

  exec { 'vault_init':
    command   => "/usr/bin/vault operator init -key-shares=${key_shares} -key-threshold=${key_threshold} -pgp-keys=\"${init_key_string}\" -tls-skip-verify -format=json > /home/vault/vault_init_output.json",
    user      => 'vault',
    logoutput => 'on_failure'
  }

  exec { 'vault_root_token':
    command   => '/usr/bin/jq -r \'.root_token\' /home/vault/vault_init_output.json > /home/vault/.vault-token',
    user      => 'vault',
    creates   => '/home/vault/.vault-token',
    logoutput => 'on_failure',
    require   => [Exec['vault_init'], Package['jq']]
  }

  exec { 'vault_unseal_keys_external_fact':
    command   => "/usr/bin/cat /home/vault/vault_init_output.json | /usr/local/bin/vault-process-init-output \"${gpg_keys_owners}\" > /etc/puppetlabs/facter/facts.d/vault_encrypted_unseal_keys.json",
    creates   => '/etc/puppetlabs/facter/facts.d/vault_encrypted_unseal_keys.json',
    logoutput => 'on_failure',
    require   => [Exec['vault_init'], Package['jq'], File['vault_process_init_output']]
  }

  file { 'vault_initialized_external_fact':
    ensure  => 'file',
    path    => '/etc/puppetlabs/facter/facts.d/vault_initialized.txt',
    content => 'vault_initialized=true',
    require => Exec['vault_init']
  }
}
