class profiles::rabbitmq (
  String $admin_user,
  String $admin_password
) {

  contain ::profiles

  realize Apt::Source['rabbitmq']

  class { '::rabbitmq':
    manage_repos      => false,
    delete_guest_user => true
  }

  rabbitmq_user { $admin_user:
    admin    => true,
    password => $admin_password
  }

  Apt::Source['rabbitmq'] -> Class['::rabbitmq'] -> Rabbitmq_user[$admin_user]
}
