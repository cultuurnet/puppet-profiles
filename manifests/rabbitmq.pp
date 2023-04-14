class profiles::rabbitmq (
  String  $admin_user,
  String  $admin_password,
  Boolean $with_tools     = true,
  String  $erlang_version = 'latest',
  String  $version        = 'latest'
) inherits ::profiles {

  if $with_tools {
    realize Package['amqp-tools']
  }

  package { 'erlang-nox':
    ensure  => $erlang_version
  }

  class { '::rabbitmq':
    manage_repos      => false,
    package_ensure    => $version,
    delete_guest_user => true,
    require           => Package['erlang-nox']
  }

  rabbitmq_user { $admin_user:
    admin    => true,
    password => $admin_password,
    require  => Class['::rabbitmq']
  }
}
