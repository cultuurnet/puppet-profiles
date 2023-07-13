class profiles::jena_fuseki (
  String           $version          = 'installed',
  Integer          $port             = 3030,
  String           $jvm_args         = '-Xmx1G',
  Integer          $query_timeout_ms = 5000,
  Hash             $datasets         = {},
  Boolean          $lvm              = false,
  Optional[String] $volume_group     = undef,
  Optional[String] $volume_size      = undef
) inherits ::profiles {

  contain ::profiles::java

  $default_shellvar_attributes = {
                                   ensure  => 'present',
                                   target  => '/etc/default/jena-fuseki',
                                   require => File['jena-fuseki service defaults'],
                                   notify  => Service['jena-fuseki']
                                 }

  realize Group['fuseki']
  realize User['fuseki']

  realize Apt::Source['publiq-tools']

  if $lvm {

    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'rdfdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/jena-fuseki/databases',
      fs_type      => 'ext4',
      owner        => 'fuseki',
      group        => 'fuseki',
      require      => [Group['fuseki'], User['fuseki']],
      before       => Package['jena-fuseki']
    }

    file { '/var/lib/jena-fuseki':
      ensure => 'directory',
      owner  => 'fuseki',
      group  => 'fuseki'
    }

    file { '/var/lib/jena-fuseki/databases':
      ensure  => 'link',
      target  => '/data/jena-fuseki/databases',
      force   => true,
      owner   => 'fuseki',
      group   => 'fuseki',
      require => [File['/var/lib/jena-fuseki'], Profiles::Lvm::Mount['rdfdata']],
      before  => Package['jena-fuseki']
    }
  }

  package { 'jena-fuseki':
    ensure  => $version,
    require => [ Group['fuseki'], User['fuseki'], Apt::Source['publiq-tools'], Class['profiles::java']]
  }

  if !$datasets.empty {
    $datasets.each |String $name, Hash $properties| {
      file { "/var/lib/jena-fuseki/databases/${name}":
        ensure => directory,
        owner  => 'fuseki',
        group  => 'fuseki',
        before => File['jena-fuseki config']
      }
    }

    $config = template('profiles/jena-fuseki/config.ttl.erb')
  } else {
    $config = undef
  }

  file { 'jena-fuseki config':
    ensure  => 'file',
    path    => '/etc/jena-fuseki/config.ttl',
    content => $config,
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
