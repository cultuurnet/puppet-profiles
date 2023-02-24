class profiles::jena_fuseki (
  String  $version          = 'latest',
  Integer $port             = 3030,
  String  $jvm_args         = '-Xmx1G',
  Integer $query_timeout_ms = 5000
) inherits ::profiles {

  $default_shellvar_attributes = {
    ensure  => 'present',
    target  => '/etc/default/jena-fuseki',
    require => File['jena-fuseki service defaults'],
    notify  => Service['jena-fuseki']
  }

  realize Group['fuseki']
  realize User['fuseki']

  realize Apt::Source['publiq-tools']

  package { 'jena-fuseki':
    ensure  => $version,
    require => [ Group['fuseki'], User['fuseki'], Apt::Source['publiq-tools']]
  }

  file { 'jena-fuseki config':
    ensure  => 'file',
    path    => '/etc/jena-fuseki/config.ttl',
    require => Package['jena-fuseki']
  }

  file { 'jena-fuseki service defaults':
    ensure => 'file',
    path   => '/etc/default/jena-fuseki'
  }

  shellvar { 'jena-fuseki PORT':
    variable => 'PORT',
    value    => $port,
    *        => $default_shellvar_attributes
  }

  shellvar { 'jena-fuseki JVM_ARGS':
    variable => 'JVM_ARGS',
    value    => $jvm_args,
    *        => $default_shellvar_attributes
  }

  shellvar { 'jena-fuseki QUERY_TIMEOUT_MS':
    variable => 'QUERY_TIMEOUT_MS',
    value    => $query_timeout_ms,
    *        => $default_shellvar_attributes
  }

  service { 'jena-fuseki':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    subscribe => [Package['jena-fuseki'], File['jena-fuseki config'], File['jena-fuseki service defaults']]
  }
}
