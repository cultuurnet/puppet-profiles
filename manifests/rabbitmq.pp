class profiles::rabbitmq {

  contain ::profiles

  realize Apt::Source['rabbitmq']

  class { '::rabbitmq':
    manage_repos      => false,
    delete_guest_user => true
  }
}
