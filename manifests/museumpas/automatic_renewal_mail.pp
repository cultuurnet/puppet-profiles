class profiles::museumpas::automatic_renewal_mail (
  Stdlib::Httpurl $api_url,
  String          $jwt_token,
  Integer         $hour      = 0,
  Integer         $minute    = 0
) inherits ::profiles {


  cron { $title:
    environment => [ 'MAILTO=infra@publiq.be'],
    command     => "/usr/bin/curl -X 'POST' -H 'Authorization: Bearer ${jwt_token}' ${api_url}/rest/system/autorenewalReminder",
    hour        => $hour,
    minute      => $minute
  }
}
