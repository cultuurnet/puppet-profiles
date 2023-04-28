class profiles::sudo inherits ::profiles {

  class { '::sudo': }

  $admin_user = $facts['ec2_metadata'] ? {
    true    => 'ubuntu',
    default => 'vagrant'
  }

  realize Group[$admin_user]
  realize User[$admin_user]

  sudo::conf { $admin_user:
    priority => '10',
    content  => "${admin_user} ALL=(ALL) NOPASSWD: ALL",
    require  => [Class['sudo'], User[$admin_user]]
  }
}
