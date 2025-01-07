class profiles::vault::gpg_key (
  String  $full_name,
  String  $email_address,
  Integer $key_length         = 4096,
  String  $gpg_keys_directory = '/etc/vault.d/gpg_keys'
) inherits ::profiles {

  $full_name_slug = downcase(regsubst($full_name, / /, '_'))

  realize Group['vault']
  realize User['vault']

  file { 'vault_gpg_key_gen_script':
    ensure  => 'file',
    path    => '/etc/vault.d/gpg_key_gen_script',
    owner   => 'vault',
    group   => 'vault',
    content => template('profiles/vault/gpg_key_gen_script.erb'),
    require => [Group['vault'], User['vault']]
  }

  exec { 'vault_gpg_key':
    command   => '/usr/bin/gpg --full-gen-key --batch /etc/vault.d/gpg_key_gen_script',
    user      => 'vault',
    unless    => "/usr/bin/gpg --fingerprint ${email_address}",
    logoutput => 'on_failure',
    require   => File['vault_gpg_key_gen_script']
  }

  exec { 'vault_gpg_key_export':
    command   => "/usr/bin/gpg --export \"${full_name}\" | /usr/bin/base64 > ${gpg_keys_directory}/${full_name_slug}.asc",
    user      => 'vault',
    logoutput => 'on_failure',
    creates   => "${gpg_keys_directory}/${full_name_slug}.asc",
    require   => Exec['vault_gpg_key']
  }
}
