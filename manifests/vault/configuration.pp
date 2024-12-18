class profiles::vault::configuration (
  Boolean $auto_unseal     = false,
  String  $service_address = '127.0.0.1',
  Integer $service_port    = 8200
) inherits ::profiles {

  $full_name     = 'Vault'
  $email_address = 'vault@publiq.be'
  $key_shares    = 5
  $key_threshold = 1

  class { 'profiles::vault::gpg_key':
    full_name     => $full_name,
    email_address => $email_address
  }
}
