class profiles::vault::secrets_engines (
) inherits ::profiles {

  realize User['vault']

  exec { 'vault_kv_secrets_engine':
    command   => '/usr/bin/vault secrets enable -version=2 kv',
    user      => 'vault',
    onlyif    => '/usr/bin/test -z "$(/usr/bin/vault secrets list -format=json | /usr/bin/jq \'.[] | select(.type == "kv")\')"',
    logoutput => 'on_failure',
    require   => User['vault']
  }
}
