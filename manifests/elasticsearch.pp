class profiles::elasticsearch (
  Optional[String] $version               = undef,
  Integer          $major_version         = if $version { Integer(split($version, /\./)[0]) } else { 5 },
  Boolean          $lvm                   = false,
  Optional[String] $volume_group          = undef,
  Optional[String] $volume_size           = undef,
  String           $initial_heap_size     = '512m',
  String           $maximum_heap_size     = '512m',
  Boolean          $backup_lvm            = false,
  Optional[String] $backup_volume_group   = undef,
  Optional[String] $backup_volume_size    = undef,
  Array[Integer]   $backup_time           = [0, 0],
  Integer          $backup_retention_days = 7
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
    init_defaults     => {
                           'ES_JAVA_OPTS' => "\"-Xms${initial_heap_size} -Xmx${maximum_heap_size}\""
                         },
    require           => [Apt::Source["elastic-${major_version}.x"], Class['::profiles::java']]
  }

  class { 'profiles::elasticsearch::backup':
    lvm            => $backup_lvm,
    volume_group   => $backup_volume_group,
    volume_size    => $backup_volume_size,
    time           => $backup_time,
    retention_days => $backup_retention_days,
    require        => Class['::elasticsearch']
  }

  # include ::profiles::elasticsearch::logging
  # include ::profiles::elasticsearch::monitoring
  # include ::profiles::elasticsearch::metrics
}
