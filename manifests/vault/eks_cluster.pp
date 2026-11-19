# One issuer, exact service-account binding and environment policy per cluster.
define profiles::vault::eks_cluster (
  Enum['acceptance', 'testing', 'production']                 $environment,
  Stdlib::Httpsurl                                            $oidc_issuer_url,
  Pattern[/\A[a-z0-9][a-z0-9-]*\z/]                           $auth_mount,
  Pattern[/\A[a-z0-9][a-z0-9-]*\z/]                           $role_name,
  Array[Pattern[/\A[a-zA-Z0-9._:-]+\z/], 1]                   $bound_audiences,
  Pattern[/\Asystem:serviceaccount:[a-z0-9-]+:[a-z0-9.-]+\z/] $bound_subject,
  String                                                      $configuration_directory = '/etc/vault.d/eks'
) {

  include ::profiles

  assert_type(Pattern[/\A[a-z0-9][a-z0-9-]*\z/], $title)
  unless $auth_mount == "eks-${title}" {
    fail("Vault EKS auth_mount must be eks-${title}")
  }

  realize Group['vault']
  realize User['vault']
  realize Package['jq']

  $policy_name = "eso-${title}-read-only"
  $policy_file = "${configuration_directory}/${title}-policy.hcl"
  $config_file = "${configuration_directory}/${title}-config.json"
  $role_file   = "${configuration_directory}/${title}-role.json"

  $jwt_config = {
    'oidc_discovery_url' => $oidc_issuer_url,
    'bound_issuer'       => $oidc_issuer_url
  }
  $jwt_role = {
    'role_type'               => 'jwt',
    'user_claim'              => 'sub',
    'bound_subject'           => $bound_subject,
    'bound_audiences'         => $bound_audiences,
    'token_policies'          => [$policy_name],
    'token_no_default_policy' => true,
    'token_ttl'               => 600,
    'token_max_ttl'           => 600
  }

  file { "vault EKS policy ${title}":
    ensure  => 'file',
    path    => $policy_file,
    owner   => 'vault',
    group   => 'vault',
    mode    => '0640',
    content => template('profiles/vault/eks-policy.hcl.erb'),
    require => [Group['vault'], User['vault']]
  }

  file { "vault EKS config ${title}":
    ensure  => 'file',
    path    => $config_file,
    owner   => 'vault',
    group   => 'vault',
    mode    => '0640',
    content => to_json_pretty($jwt_config),
    require => [Group['vault'], User['vault']]
  }

  file { "vault EKS role ${title}":
    ensure  => 'file',
    path    => $role_file,
    owner   => 'vault',
    group   => 'vault',
    mode    => '0640',
    content => to_json_pretty($jwt_role),
    require => [Group['vault'], User['vault']]
  }

  # Compare live state on every run, so drift and missing remote configuration
  # are repaired even when the local files have not changed.
  $json_comparison = '.data as $live | $desired[0] | to_entries | all(.[]; . as $entry | $live[$entry.key] == $entry.value)'
  $policy_check = join([
    "/usr/bin/vault read -format=json sys/policies/acl/${policy_name} | ",
    "/usr/bin/jq -e --rawfile policy ${policy_file} '.data.policy == \$policy'"
  ], '')
  $config_check = join([
    "/usr/bin/vault read -format=json auth/${auth_mount}/config | ",
    "/usr/bin/jq -e --slurpfile desired ${config_file} '${json_comparison}'"
  ], '')
  $role_check = join([
    "/usr/bin/vault read -format=json auth/${auth_mount}/role/${role_name} | ",
    "/usr/bin/jq -e --slurpfile desired ${role_file} '${json_comparison}'"
  ], '')

  exec { "vault EKS policy ${title}":
    command   => "/usr/bin/vault policy write ${policy_name} ${policy_file}",
    unless    => $policy_check,
    user      => 'vault',
    logoutput => 'on_failure',
    require   => [User['vault'], Package['jq'], File["vault EKS policy ${title}"]]
  }

  exec { "vault EKS auth ${title}":
    command   => "/usr/bin/vault auth enable -path=${auth_mount} jwt",
    unless    => "/usr/bin/vault auth list -format=json | /usr/bin/jq -e '.[\"${auth_mount}/\"].type == \"jwt\"'",
    user      => 'vault',
    logoutput => 'on_failure',
    require   => [User['vault'], Package['jq']]
  }

  exec { "vault EKS config ${title}":
    command   => "/usr/bin/vault write auth/${auth_mount}/config @${config_file}",
    unless    => $config_check,
    user      => 'vault',
    logoutput => 'on_failure',
    require   => [Exec["vault EKS auth ${title}"], File["vault EKS config ${title}"]]
  }

  exec { "vault EKS role ${title}":
    command   => "/usr/bin/vault write auth/${auth_mount}/role/${role_name} @${role_file}",
    unless    => $role_check,
    user      => 'vault',
    logoutput => 'on_failure',
    require   => [Exec["vault EKS config ${title}"], Exec["vault EKS policy ${title}"], File["vault EKS role ${title}"]]
  }
}
