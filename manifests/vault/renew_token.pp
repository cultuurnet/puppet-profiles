define profiles::vault::renew_token (
  String $key,
  String $ensure = 'present'
) {

  include ::profiles

  $secret = lookup($title)
  $token_to_renew = $secret[$key]

  cron { "Renew Vault service token ${title}":
    command     => "/usr/bin/vault token renew ${token_to_renew}",
    environment => ['MAILTO=infra+cron@publiq.be'],
    user        => 'vault',
    hour        => '0',
    minute      => '15',
    ensure      => $ensure
  }
}
