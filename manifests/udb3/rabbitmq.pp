class profiles::udb3::rabbitmq (
  String  $vhost,
  String  $admin_user,
  String  $admin_password,
  Boolean $with_tools      = true
) inherits ::profiles {

  class { '::profiles::rabbitmq':
    admin_user     => $admin_user,
    admin_password => $admin_password,
    with_tools     => $with_tools
  }

  rabbitmq_vhost { $vhost:
    ensure  => present
  }

  rabbitmq_user_permissions { "${admin_user}@${vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*'
  }

  rabbitmq_exchange { "udb3.x.domain-events@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    type        => 'topic',
    internal    => false,
    auto_delete => false,
    durable     => true
  }

  rabbitmq_queue { "uitpas.q.udb3-domain-events-api@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "udb3.x.domain-events@uitpas.q.udb3-domain-events-api@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => 'api',
    arguments        => {}
  }

  rabbitmq_queue { "uitpas.q.udb3-domain-events-cli@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "udb3.x.domain-events@uitpas.q.udb3-domain-events-cli@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => 'cli',
    arguments        => {}
  }

  rabbitmq_queue { "uitpas.q.udb3-domain-events-related@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "udb3.x.domain-events@uitpas.q.udb3-domain-events-related@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => 'related',
    arguments        => {}
  }

  rabbitmq_exchange { "search.x.domain-events@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    type        => 'topic',
    internal    => false,
    auto_delete => false,
    durable     => true
  }

  rabbitmq_queue { "search.q.udb3-domain-events-api@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "udb3.x.domain-events@search.q.udb3-domain-events-api@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => 'api',
    arguments        => {}
  }

  rabbitmq_binding { "search.x.domain-events@search.q.udb3-domain-events-api@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => 'api',
    arguments        => {}
  }

  rabbitmq_queue { "search.q.udb3-domain-events-cli@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "udb3.x.domain-events@search.q.udb3-domain-events-cli@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => 'cli',
    arguments        => {}
  }

  rabbitmq_binding { "search.x.domain-events@search.q.udb3-domain-events-cli@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => 'cli',
    arguments        => {}
  }

  rabbitmq_queue { "search.q.udb3-domain-events-related@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }

  rabbitmq_binding { "udb3.x.domain-events@search.q.udb3-domain-events-related@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => 'related',
    arguments        => {}
  }

  rabbitmq_binding { "search.x.domain-events@search.q.udb3-domain-events-related@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => 'related',
    arguments        => {}
  }

  rabbitmq_exchange { "uitpas.x.uitpas-events@${vhost}":
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

  rabbitmq_binding { "uitpas.x.uitpas-events@udb3.q.uitpas-events@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => '#',
    arguments        => {}
  }

  rabbitmq_binding { "udb3.x.domain-events@rdf.q.udb3-domain-events@${vhost}":
    user             => $admin_user,
    password         => $admin_password,
    destination_type => 'queue',
    routing_key      => '#',
    arguments        => {}
  }

  rabbitmq_queue { "rdf.q.udb3-domain-events@${vhost}":
    user        => $admin_user,
    password    => $admin_password,
    durable     => true,
    auto_delete => false
  }
}
