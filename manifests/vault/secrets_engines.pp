class profiles::vault::secrets_engines (
) inherits ::profiles {

  $puppet_secrets_path = 'puppet'

  realize User['vault']

  exec { 'vault_puppet_kv_secrets_engine':
    command   => "/usr/bin/vault secrets enable -version=2 -path=${puppet_secrets_path} kv",
    user      => 'vault',
    unless    => "/usr/bin/vault secrets list -format=json | /usr/bin/jq -e '.\"${puppet_secrets_path}/\"'",
    logoutput => 'on_failure',
    require   => User['vault']
  }
}
