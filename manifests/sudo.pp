class profiles::sudo (
  Optional[String] $admin_user = undef
) inherits ::profiles {

  class { '::sudo': }

  if $admin_user {
    sudo::conf { $admin_user:
      priority => '10',
      content  => "${admin_user} ALL=(ALL) NOPASSWD: ALL"
    }
  }
}
