class profiles::vault::gpg_key (
  String  $full_name,
  String  $email_address,
  Integer $key_length    = 4096
) inherits ::profiles {

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
}
