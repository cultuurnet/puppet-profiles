class profiles::meilisearch (
  String                     $version        = 'installed',
  String                     $environment    = 'development',
  String                     $master_key     = '',
  String                     $http_addr      = 'localhost:7700',
  String                     $db_path        = '/var/lib/meilisearch/data',
  String                     $dump_dir       = '/var/lib/meilisearch/dumps',
  String                     $snapshot_dir   = '/var/lib/meilisearch/snapshots',
  Optional[Variant[Hash]]    $extra_config   = {},
  Enum['running', 'stopped'] $service_status = 'running'
) inherits ::profiles {

  realize Group['meilisearch']
  realize User['meilisearch']

  realize Apt::Source['publiq-tools']

  package { 'meilisearch':
    ensure  => $version,
    require => [User['meilisearch'],Apt::Source['publiq-tools']],
    notify  => Service['meilisearch']
  }

  file { 'meilisearch_config':
    ensure => 'file',
    path    => '/etc/meilisearch.toml',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('profiles/meilisearch/meilisearch.toml.erb'),
    require => [Package['meilisearch']],
    notify  => Service['meilisearch']
  }

  service { 'meilisearch':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 }
  }
}

