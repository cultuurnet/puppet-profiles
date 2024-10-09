class profiles::newrelic::infrastructure::service (
  Enum['running', 'stopped'] $status = 'running'
) inherits ::profiles {

  service { 'newrelic-infra':
    ensure    => $status,
    hasstatus => true,
    enable    => $status ? {
                   'running' => true,
                   'stopped' => false
                 }
  }
}
