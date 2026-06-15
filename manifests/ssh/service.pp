class profiles::ssh::service inherits ::profiles {

  service { 'ssh':
    ensure => 'running',
    enable => true
  }
}
