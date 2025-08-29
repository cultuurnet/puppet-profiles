class profiles::systemd (
  String $journald_system_max_use = '500M'
) inherits ::profiles {

  class { 'systemd':
    journald_settings => {
                           'SystemMaxUse' => $journald_system_max_use
                         }
  }
}
