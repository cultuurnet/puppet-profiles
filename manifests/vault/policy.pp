define profiles::vault::policy (
  String $policy,
  String $policies_directory = '/etc/vault.d/policies'
) {

  include ::profiles

  realize Group['vault']
  realize User['vault']

  file { "vault policy ${title}":
    ensure  => 'file',
    path    => "${policies_directory}/${title}.hcl",
    owner   => 'vault',
    group   => 'vault',
    content => $policy,
    require => [Group['vault'], User['vault']]
  }

  exec { "vault_write_policy ${title}":
    command     => "/usr/bin/vault policy write ${title} ${policies_directory}/${title}.hcl",
    user        => 'vault',
    refreshonly => true,
    logoutput   => 'on_failure',
    require     => User['vault'],
    subscribe   => File["vault policy ${title}"]
  }
}
