class profiles::systemd::reload inherits ::profiles {

  exec { 'systemd daemon reload':
    command     => '/usr/bin/systemctl daemon-reload',
    cwd         => '/',
    logoutput   => true,
    refreshonly => true
  }
}
