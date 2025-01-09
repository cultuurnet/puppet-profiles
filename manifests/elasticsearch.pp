class profiles::elasticsearch (
  Optional[String] $version                             = undef,
  Integer          $major_version                       = if $version { Integer(split($version, /\./)[0]) } else { 5 },
  Boolean          $secure_remote_access                = false,
  Optional[String] $secure_remote_access_user           = undef,
  Optional[String] $secure_remote_access_password       = undef,
  Optional[String] $secure_remote_access_plugin_version = undef,
  Boolean          $lvm                                 = false,
  Optional[String] $volume_group                        = undef,
  Optional[String] $volume_size                         = undef,
  String           $initial_heap_size                   = '512m',
  String           $maximum_heap_size                   = '512m',
  Boolean          $backup                              = true,
  Boolean          $backup_lvm                          = false,
  Optional[String] $backup_volume_group                 = undef,
  Optional[String] $backup_volume_size                  = undef,
  Integer          $backup_hour                         = 0,
  Integer          $backup_retention_days               = 7
) inherits ::profiles {

  if ($version and $major_version) {
    if Integer(split($version, /\./)[0]) != $major_version {
      fail("Profiles::Elasticsearch: incompatible combination of 'version' and 'major_version' parameters")
    }
  }

  $datadir = '/var/lib/elasticsearch'

  contain ::profiles::java

  realize Apt::Source["elastic-${major_version}.x"]
  realize Group['elasticsearch']
  realize User['elasticsearch']

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'elasticsearchdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/elasticsearch',
      fs_type      => 'ext4',
      owner        => 'elasticsearch',
      group        => 'elasticsearch',
      require      => [Group['elasticsearch'], User['elasticsearch']],
      before       => Class['::elasticsearch']
    }

    mount { $datadir:
      ensure  => 'mounted',
      device  => '/data/elasticsearch',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['elasticsearchdata'], File[$datadir]],
      before  => Class['elasticsearch']
    }
  }

  file { $datadir:
    ensure  => 'directory',
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
    require => [Group['elasticsearch'], User['elasticsearch']],
    before  => Class['elasticsearch']
  }

  augeas { 'elasticsearch-remove-heap-configuration-from-jvm.options':
    lens    => 'SimpleLines.lns',
    incl    => '/etc/elasticsearch/jvm.options',
    context => '/files/etc/elasticsearch/jvm.options',
    changes => [
                 "rm *[. =~ regexp('^-Xms.*')]",
                 "rm *[. =~ regexp('^-Xmx.*')]"
               ],
    require => Class['elasticsearch::package'],
    before  => Class['elasticsearch::config']
  }

  if $secure_remote_access {
    unless ($secure_remote_access_user and $secure_remote_access_password and $secure_remote_access_plugin_version) {
      fail("with secure_remote_access enabled, expects a value for 'secure_remote_access_user' and 'secure_remote_access_password' and 'secure_remote_access_plugin_version'")
    }

    realize Apt::Source['publiq-tools']

    package { 'elasticsearch-readonlyrest':
      ensure  => "${secure_remote_access_plugin_version}-es${version}",
      require => Apt::Source['publiq-tools'],
      before  => Class['elasticsearch']
    }

    $es_config = {
      'network.host'                           => [ "${::ipaddress_eth0}", "127.0.0.1" ],
      'http.cors.enabled'                      => true,
      'http.cors.allow-origin'                 => "*",
      'http.cors.allow-methods'                => "OPTIONS, HEAD, GET, POST, PUT, DELETE",
      'http.cors.allow-headers'                => "X-Requested-With, X-Auth-Token, Content-Type, Content-Length",
      'readonlyrest.enable'                    => true,
      'readonlyrest.response_if_req_forbidden' => 'Access denied!!!',
      'readonlyrest.access_control_rules'      => [
        {
          'name'     => 'Accept all local requests without authentication',
          'type'     => 'allow',
          'hosts'    => ['127.0.0.1']
        },
        {
          'name'     => 'Accept all write requests with basic authentication',
          'auth_key' => "${secure_remote_access_user}:${secure_remote_access_password}",
          'type'     => 'allow',
          'method'   => ['POST','PUT','DELETE']
        },
        {
          'name'     => 'Accept all read requests without authentication',
          'type'     => 'allow',
          'indices'  => [ '*' ],
          'actions'  => [ 'indices:data/read/*' ]
        },
        {
          'name'     => 'Deny all write requests',
          'type'     => 'forbid',
          'indices'  => [ '*' ],
          'actions'  => [ 'indices:data/write/*' ]
        }
      ]
    }

    $es_plugins = {
      'readonlyrest' => {
        'source' => '/opt/elasticsearch-readonlyrest/readonlyrest-1.16.16.zip'
      }
    }
  } else {
    $es_config  = undef
    $es_plugins = undef
  }

  class { '::elasticsearch':
    version           => $version ? {
                           undef   => false,
                           default => $version
                         },
    manage_repo       => false,
    api_timeout       => 30,
    restart_on_change => true,
    datadir           => $datadir,
    manage_datadir    => false,
    config            => $es_config,
    plugins           => $es_plugins,
    init_defaults     => {
                           'ES_JAVA_OPTS' => "\"-Xms${initial_heap_size} -Xmx${maximum_heap_size}\""
                         },
    require           => [Apt::Source["elastic-${major_version}.x"], Class['::profiles::java']]
  }

  if $backup {
    class { 'profiles::elasticsearch::backup':
      lvm            => $backup_lvm,
      volume_group   => $backup_volume_group,
      volume_size    => $backup_volume_size,
      dump_hour      => $backup_hour,
      retention_days => $backup_retention_days,
      require        => Class['::elasticsearch']
    }
  }

  # include ::profiles::elasticsearch::logging
  # include ::profiles::elasticsearch::monitoring
  # include ::profiles::elasticsearch::metrics
}
