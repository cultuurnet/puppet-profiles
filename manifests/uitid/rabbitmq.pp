class profiles::uitid::rabbitmq (
  String $vhost,
  String $admin_user     = $profiles::rabbitmq::admin_user,
  String $admin_password = $profiles::rabbitmq::admin_password
) inherits ::profiles {

  contain ::profiles::rabbitmq

  rabbitmq_vhost { $vhost:
    ensure => present
  }

  rabbitmq_user_permissions { "${admin_user}@${vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*'
  }

  rabbitmq_exchange { "uitid.x.activities@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    type        => 'topic',
    internal    => false,
    auto_delete => false,
    durable     => true
  }

  rabbitmq_queue { "uitid.q.activities-sapi@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "uitid.x.activities@uitid.q.activities-sapi@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => '#',
    arguments        => {}
  }
}
