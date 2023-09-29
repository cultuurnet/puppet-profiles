class profiles::museumpas::automatic_mandates (
  Enum['present', 'absent'] $ensure    = 'present',
  Optional[Stdlib::Httpurl] $api_url   = undef,
  Optional[String]          $jwt_token = undef,
  Integer                   $hour      = 0,
  Integer                   $minute    = 0
) inherits ::profiles {

  if $ensure == 'present' {
    unless $api_url   { fail("Class ${title} expects a value for parameter 'api_url'") }
    unless $jwt_token { fail("Class ${title} expects a value for parameter 'jwt_token'") }
  }

  cron { $title:
    ensure      => $ensure,
    environment => [ 'MAILTO=infra@publiq.be'],
    command     => "/usr/bin/curl -X 'POST' -H 'Authorization: Bearer ${jwt_token}' ${api_url}/rest/system/autorenewalInspectPending",
    hour        => $hour,
    minute      => $minute
  }
}
