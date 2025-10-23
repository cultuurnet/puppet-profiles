class profiles::uitid::api::cron (
  Integer $portbase = 4800
) inherits ::profiles {

  $http_port = String($portbase + 80)
  $base_url  = "http://127.0.0.1:${http_port}"

  cron { 'Clear UiTiD application caches':
    command  => "/usr/bin/curl --fail --silent --output /dev/null '${base_url}/uitid/rest/bootstrap/clearcaches'",
    hour     => [4, 16],
    minute   => 20,
    weekday  => '*',
    monthday => '*',
    month    => '*'
  }

  cron { 'Clear UiTiD JPA cache':
    command  => "/usr/bin/curl --fail --silent --output /dev/null '${base_url}/uitid/rest/bootstrap/clearJpaCache'",
    hour     => [4, 16],
    minute   => 20,
    weekday  => '*',
    monthday => '*',
    month    => '*'
  }
}
