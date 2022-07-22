class profiles::publiq::versions::service inherits ::profiles {

  service { 'publiq-versions':
    ensure    => 'running',
    hasstatus => true,
    enable    => true
  }
}
