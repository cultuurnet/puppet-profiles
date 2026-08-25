class profiles::elasticsearch::container (
  String                  $version,
  String                  $image                 = 'docker.elastic.co/elasticsearch/elasticsearch',
  Boolean                 $lvm                   = false,
  Optional[String]        $volume_group          = undef,
  Optional[String]        $volume_size           = undef,
  Optional[String]        $log_volume_size       = undef,
  String                  $initial_heap_size     = '512m',
  String                  $maximum_heap_size     = '512m',
  Stdlib::IP::Address::V4 $listen_address        = '127.0.0.1',
  Boolean                 $backup                = true,
  Boolean                 $backup_lvm            = false,
  Optional[String]        $backup_volume_group   = undef,
  Optional[String]        $backup_volume_size    = undef,
  Integer                 $backup_hour           = 0,
  Integer                 $backup_retention_days = 7
) inherits ::profiles {

  include profiles::docker

  $major_version = Integer(split($version, /\./)[0])
  $datadir       = '/var/lib/elasticsearch'
  $logdir        = '/var/log/elasticsearch'

  realize Group['elasticsearch']
  realize User['elasticsearch']

  # Stop the native install so it doesn't fight the container for the data directory / port 9200.
  service { 'elasticsearch':
    ensure => stopped,
    enable => false,
  }

  # ES's standard host-level prerequisite. Not currently set anywhere in this repo for the
  # native installs either; wiring it here rather than assuming it's unnecessary.
  class { 'profiles::sysctl':
    settings => {
      'vm.max_map_count' => { value => '262144' },
    },
  }

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
    }

    mount { $datadir:
      ensure  => 'mounted',
      device  => '/data/elasticsearch',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['elasticsearchdata'], File[$datadir]],
    }

    if $log_volume_size {
      profiles::lvm::mount { 'elasticsearchlogs':
        volume_group => $volume_group,
        size         => $log_volume_size,
        mountpoint   => '/data/elasticsearchlogs',
        fs_type      => 'ext4',
        owner        => 'elasticsearch',
        group        => 'elasticsearch',
        require      => [Group['elasticsearch'], User['elasticsearch']],
      }

      file { $logdir:
        ensure  => 'directory',
        owner   => 'elasticsearch',
        group   => 'elasticsearch',
        require => [Group['elasticsearch'], User['elasticsearch']],
      }

      mount { $logdir:
        ensure  => 'mounted',
        device  => '/data/elasticsearchlogs',
        fstype  => 'none',
        options => 'rw,bind',
        require => [Profiles::Lvm::Mount['elasticsearchlogs'], File[$logdir]],
      }
    }
  }

  file { $datadir:
    ensure  => 'directory',
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
    require => [Group['elasticsearch'], User['elasticsearch']],
  }

  # Matches the xpack posture the native class already forces for major_version >= 8 —
  # containerizing shouldn't change security behaviour, only how the process is launched.
  $xpack_env = $major_version >= 8 ? {
    true    => [
                 'xpack.security.enabled=false',
                 'xpack.security.transport.ssl.enabled=false',
                 'xpack.security.http.ssl.enabled=false',
               ],
    default => [],
  }

  $log_volumes = $log_volume_size ? {
    undef   => [],
    default => ["${logdir}:/usr/share/elasticsearch/logs"],
  }

  # NOTE: the official image's `elasticsearch` user is uid 1000; the native package's system
  # user (owning $datadir/$logdir above) is whatever uid Debian assigned it, almost certainly
  # not 1000. This needs reconciling before running against real data — an unverified UID
  # mismatch would leave the container unable to write to a data directory that mounted fine.
  docker::run { 'elasticsearch':
    image            => "${image}:${version}",
    net              => 'host',
    volumes          => ["${datadir}:/usr/share/elasticsearch/data"] + $log_volumes,
    env              => [
                          "ES_JAVA_OPTS=-Xms${initial_heap_size} -Xmx${maximum_heap_size}",
                          'discovery.type=single-node',
                        ] + $xpack_env,
    extra_parameters => ['--ulimit', 'memlock=-1:-1'],
    health_check_cmd => "curl -sf http://${listen_address}:9200/_cluster/health || exit 1",
    require          => [Class['profiles::docker'], Service['elasticsearch'], File[$datadir]],
  }

  class { 'profiles::elasticsearch::backup':
    schedule       => $backup,
    lvm            => $backup_lvm,
    volume_group   => $backup_volume_group,
    volume_size    => $backup_volume_size,
    dump_hour      => $backup_hour,
    retention_days => $backup_retention_days,
    require        => Docker::Run['elasticsearch'],
  }
}
