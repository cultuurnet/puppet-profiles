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
}
