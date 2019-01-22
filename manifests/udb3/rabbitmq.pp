class profiles::udb3::rabbitmq (
  String $vhost,
  String $admin_user     = $profiles::rabbitmq::admin_user,
  String $admin_password = $profiles::rabbitmq::admin_password
)
{
  contain ::profiles
  contain ::profiles::rabbitmq

  rabbitmq_vhost { $vhost:
    ensure  => present
  }

  rabbitmq_user_permissions { "${admin_user}@${vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*'
  }

  rabbitmq_exchange { "udb2.x.entry@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    type        => 'topic',
    internal    => false,
    auto_delete => false,
    durable     => true
  }

  rabbitmq_exchange { "udb3.x.domain-events@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    type        => 'topic',
    internal    => false,
    auto_delete => false,
    durable     => true
  }

  rabbitmq_exchange { "cdbxml.x.entry@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    type        => 'topic',
    internal    => false,
    auto_delete => false,
    durable     => true
  }

  rabbitmq_queue { "udb3.q.udb2-entry@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "udb2.x.entry@udb3.q.udb2-entry@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => '#',
    arguments        => {}
  }

  rabbitmq_queue { "cdbxml.q.udb3-domain-events@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_queue { "uitpas.q.udb3-domain-events@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "udb3.x.domain-events@cdbxml.q.udb3-domain-events@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => '#',
    arguments        => {}
  }

  rabbitmq_binding { "udb3.x.domain-events@uitpas.q.udb3-domain-events@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => '#',
    arguments        => {}
  }

  rabbitmq_queue { "solr.q.udb3-cdbxml@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "cdbxml.x.entry@solr.q.udb3-cdbxml@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => '#',
    arguments        => {}
  }

  rabbitmq_exchange { "uitid.x.uitpas-events@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    type        => 'topic',
    internal    => false,
    auto_delete => false,
    durable     => true
  }

  rabbitmq_queue { "udb3.q.uitpas-events@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "uitid.x.uitpas-events@udb3.q.uitpas-events@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => '#',
    arguments        => {}
  }

  rabbitmq_exchange { "imports.x.entry@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    type        => 'topic',
    internal    => false,
    auto_delete => false,
    durable     => true
  }

  rabbitmq_queue { "udb3.q.imports-entry@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "imports.x.entry@udb3.q.imports-entry@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => '#',
    arguments        => {}
  }
}
