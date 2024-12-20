class profiles::vault::service (
  Enum['running', 'stopped'] $service_status = 'running'
) inherits ::profiles {

  service { 'vault':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 }
  }
}
