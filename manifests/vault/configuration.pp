class profiles::vault::configuration (
  String  $service_address = '127.0.0.1'
) inherits ::profiles {

  shellvar { 'VAULT_ADDR environment variable':
    ensure   => 'present',
    target   => '/etc/environment',
    variable => 'VAULT_ADDR',
    value    => 'https://127.0.0.1:8200'
  }
}
