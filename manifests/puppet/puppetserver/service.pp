class profiles::puppet::puppetserver::service (
  Enum['running', 'stopped'] $status = 'running'
) inherits ::profiles {

  service { 'puppetserver':
    ensure    => $status,
    hasstatus => true,
    enable    => $status ? {
                   'running' => true,
                   'stopped' => false
                 }
  }
}
