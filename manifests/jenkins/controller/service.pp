class profiles::jenkins::controller::service inherits ::profiles {

  service { 'jenkins':
    ensure    => 'running',
    hasstatus => true,
    enable    => true
  }
}
