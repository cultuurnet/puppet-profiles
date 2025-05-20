define profiles::vault::renew_token (
  String $token_value,
  String $ensure = 'present'
) {

  include ::profiles

  cron { "Renew Vault service token ${title}":
    command     => "/usr/bin/vault token renew ${token_value}",
    environment => ['MAILTO=infra+cron@publiq.be'],
    user        => 'vault',
    hour        => '0',
    minute      => '15',
    ensure      => $ensure
  }
}
