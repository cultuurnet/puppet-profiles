class profiles::rabbitmq (
  String  $admin_user,
  String  $admin_password,
  Boolean $with_tools      = true
) inherits ::profiles {

  include ::profiles::packages
  include ::profiles::apt::updates

  realize Profiles::Apt::Update['rabbitmq']

  if $with_tools {
    realize Package['amqp-tools']
  }

  class { '::rabbitmq':
    manage_repos      => false,
    delete_guest_user => true
  }

  rabbitmq_user { $admin_user:
    admin    => true,
    password => $admin_password
  }

  Profiles::Apt::Update['rabbitmq'] -> Class['::rabbitmq'] -> Rabbitmq_user[$admin_user]
}
