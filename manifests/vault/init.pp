class profiles::vault::init (
  Boolean $auto_unseal   = false,
  Integer $key_threshold = 1,
  Hash    $gpg_keys      = {}
) inherits ::profiles {

  if (!$auto_unseal and empty($gpg_keys)) {
    fail('without auto_unseal, at least one GPG key has to be provided')
  }

  if ($auto_unseal and $key_threshold > 1) {
    fail('with auto_unseal, key threshold cannot be higher than 1')
  }

  $gpg_keys_directory = '/etc/vault.d/gpg_keys'
  $gpg_keys_exports   = $gpg_keys.map |Array $gpg_key| { "${gpg_keys_directory}/${gpg_key[0]}.asc" }

  realize Group['vault']
  realize User['vault']
  realize Package['jq']

  file { 'vault_gpg_keys':
    ensure => 'directory',
    path    => $gpg_keys_directory,
    owner   => 'vault',
    group   => 'vault',
    require => [Group['vault'], User['vault']]
  }

  if $auto_unseal {
    $key_shares      = 1 + length($gpg_keys)
    $full_name       = 'Vault'
    $email_address   = 'vault@publiq.be'
    $init_key_string = join(["${gpg_keys_directory}/vault.asc"] + $gpg_keys_exports, ',')

    class { 'profiles::vault::gpg_key':
      full_name          => $full_name,
      email_address      => $email_address,
      gpg_keys_directory => $gpg_keys_directory,
      before             => Exec['vault_init'],
      require            => File['vault_gpg_keys']
    }
  } else {
    $key_shares      = length($gpg_keys)
    $init_key_string = join($gpg_keys_exports, ',')
  }

  $gpg_keys.each | $fingerprint, $attributes| {
    gnupg_key { $fingerprint:
      ensure      => 'present',
      key_id      => $fingerprint,
      user        => 'vault',
      key_content => $attributes['key'],
      key_type    => 'public',
      tag         => $attributes['tag'],
      require     => User['vault']
    }

    exec { "export_gpg_key ${fingerprint}":
      command   => "/usr/bin/gpg --export | /usr/bin/base64 > ${gpg_keys_directory}/${fingerprint}.asc",
      user      => 'vault',
      creates   => "${gpg_keys_directory}/${fingerprint}.asc",
      logoutput => 'on_failure',
      require   => [File['vault_gpg_keys'], Gnupg_key[$fingerprint]],
      before    => Exec['vault_init']
    }
  }

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
