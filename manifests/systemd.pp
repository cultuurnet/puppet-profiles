class profiles::systemd (
  String $system_max_use   = '500M'
) inherits ::profiles {
  include systemd

  systemd::journald { 'SystemMaxUse':
    settings => {
      'Journal' => {
        'SystemMaxUse' => $system_max_use,
      },
    },
  }
}
