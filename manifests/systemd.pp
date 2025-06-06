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
    notify => Exec['systemd-journald-reload'],
  }

  exec { 'systemd-journald-reload':
    command     => '/bin/systemctl reload systemd-journald',
    refreshonly => true,
    path        => ['/bin', '/usr/bin'],
  }
}
