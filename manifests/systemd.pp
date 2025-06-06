class profiles::systemd (
  String $system_max_use   = '500M'
) inherits profiles {
  class {
    'systemd': journald_settings => {
      SystemMaxUse => $system_max_use,
    }
  }
}
