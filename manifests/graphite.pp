class profiles::graphite (
  String                     $secret_key,
  Boolean                    $lvm                       = false,
  Optional[String]           $volume_group              = undef,
  Optional[String]           $volume_size               = undef,
  Boolean                    $auth                      = false,
  String                     $servername,
  Optional[Array]            $serveraliases             = [],
  Stdlib::IP::Address::V4    $service_address           = '127.0.0.1',
  Stdlib::Port::Unprivileged $service_port              = 8080,
  Enum['running', 'stopped'] $service_status            = 'running',
) inherits ::profiles {

  $carbon_conf_dir       = '/etc/carbon'
  $storage_dir           = '/var/lib/graphite'
  $local_data_dir        = "${storage_dir}/whisper"
  $graphite_web_conf_dir = '/etc/graphite'

  $storage_aggregation_rules = {
    '00_min' => {
      'pattern' => '\.min$',
      'factor'  => '0.5',
      'method'  => 'min'
    },
    '01_max' => {
      'pattern' => '\.max$',
      'factor'  => '0.5',
      'method'  => 'max'
    },
    '02_sum' => {
      'pattern' => '\.count$',
      'factor'  => '0.5',
      'method'  => 'sum'
    },
    '99_default_avg' => {
      'pattern' => '.*',
      'factor'  => '0.5',
      'method'  => 'average'
    }
  }

  $storage_schemas = [
   {
     'name'       => 'collectd',
     'pattern'    => '^collectd\.',
     'retentions' => '10s:7d,600s:30d,86400s:365d',
   },
   {
     'name'       => 'carbon',
     'pattern'    => '^carbon\.',
     'retentions' => '10s:7d,600s:30d',
   },
   {
     'name'       => 'local',
     'pattern'    => '^local\.',
     'retentions' => '10s:7d,600s:30d',
   },
   {
     'name'       => 'office',
     'pattern'    => '^office\.',
     'retentions' => '300s:180d,86400s:365d',
   },
   {
     'name'       => 'cid',
     'pattern'    => '^cid\.',
     'retentions' => '3600s:180d,86400s:365d',
   },
   {
     'name'       => 'demo',
     'pattern'    => '^demo\.',
     'retentions' => '1s:2d',
   },
   {
     'name'       => 'default',
     'pattern'    => '.*',
     'retentions' => '10s:7d,600s:30d',
   }
  ]

  realize Group['_graphite']
  realize User['_graphite']

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'graphitedata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/graphite',
      fs_type      => 'ext4',
      owner        => '_graphite',
      group        => '_graphite',
      require      => [Group['_graphite'], User['_graphite']],
    }

    file { 'Graphite install dir':
      ensure  => 'directory',
      path    => $storage_dir,
      group   => '_graphite',
      owner   => '_graphite',
      require => [Group['_graphite'],User['_graphite']],
    }

    file { 'Graphite data dir':
      ensure  => 'directory',
      path    => $local_data_dir,
      group   => '_graphite',
      owner   => '_graphite',
      require => [Group['_graphite'],User['_graphite'],File['Graphite install dir']],
    }

    mount { $local_data_dir:
      ensure  => 'mounted',
      device  => '/data/graphite',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['graphitedata'],File['Graphite data dir']],
      before  => Package['graphite-carbon']
    }
  }

  realize Apt::Source['publiq-tools']

  realize Package['graphite-carbon']
  realize Package['graphite-web']
  realize Package['uwsgi']
  realize Package['uwsgi-plugin-python3']

  realize Firewall['300 accept webcache traffic']
  realize Firewall['500 accept carbon traffic']

  file { "${carbon_conf_dir}/carbon.conf":
    ensure  => file,
    content => template('profiles/graphite/carbon.conf.erb'),
    mode    => '0644',
    owner   => '_graphite',
    group   => '_graphite',
    notify  => Service['carbon-cache']
  }

  file { "${carbon_conf_dir}/storage-schemas.conf":
    ensure  => file,
    content => template('profiles/graphite/storage-schemas.conf.erb'),
    mode    => '0644',
    owner   => '_graphite',
    group   => '_graphite',
    notify  => Service['carbon-cache']
  }

  file { "${carbon_conf_dir}/storage-aggregation.conf":
    ensure  => file,
    content => template('profiles/graphite/storage-aggregation.conf.erb'),
    mode    => '0644',
    owner   => '_graphite',
    group   => '_graphite',
    notify  => Service['carbon-cache']
  }

  file { "${graphite_web_conf_dir}/local_settings.py":
    ensure  => file,
    content => template('profiles/graphite/local_settings.py.erb'),
    mode    => '0644',
    owner   => '_graphite',
    group   => '_graphite',
    notify  => Service['graphite-web'],
    require     => Package['graphite-web']
  }

  exec { 'Initial django db creation':
    command     => '/usr/bin/django-admin migrate --settings=graphite.settings',
    cwd         => '/usr/lib/python3/dist-packages/graphite',
    user        => '_graphite',
    group       => '_graphite',
    creates     => "${storage_dir}/graphite.db",
    require     => Package['graphite-web']
  }

  systemd::unit_file { 'graphite-web.service':
    content => template('profiles/graphite/graphite-web.service.erb'),
    enable  => true,
    active  => true,
    require => [Package['uwsgi'],Package['uwsgi-plugin-python3']]
  }

  service { 'carbon-cache':
    ensure    => $service_status,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    hasstatus => true
  }

  service { 'graphite-web':
    ensure    => $service_status,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    hasstatus => true
  }

  profiles::apache::vhost::graphite_web { "http://${servername}":
    destination         => "http://${service_address}:${service_port}/",
    aliases             => $serveraliases,
    auth_openid_connect => $auth
  }
}
