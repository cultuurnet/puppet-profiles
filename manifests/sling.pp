class profiles::sling inherits ::profiles {

  realize Apt::Source['publiq-tools']

  package { 'sling':
    ensure  => 'latest',
    require => Apt::Source['publiq-tools']
  }

  file { '/root/.sling':
    ensure => 'directory'
  }

  concat { '/root/.sling/env.yaml':
    ensure  => 'present',
    order   => 'numeric',
    require => File['/root/.sling']
  }

  concat::fragment { 'sling_connections_header':
    target  => '/root/.sling/env.yaml',
    content => "connections:\n",
    order   => 1
  }

  shellvar { 'system DBUS_SESSION_BUS_ADDRESS':
    ensure   => 'present',
    target   => '/etc/environment',
    variable => 'DBUS_SESSION_BUS_ADDRESS',
    value    => '/dev/null'
  }
}
