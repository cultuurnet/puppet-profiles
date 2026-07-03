class profiles::qdrant (
  Optional[String]           $version        = 'installed',
  Stdlib::IP::Address::V4    $listen_address = '127.0.0.1',
  Boolean                    $lvm            = false,
  Optional[String]           $volume_group   = undef,
  Optional[String]           $volume_size    = undef,
  Enum['running', 'stopped'] $service_status = 'running'
) inherits ::profiles {

  $basedir = '/var/lib/qdrant'
  $config  = {
               'storage' => {
                              'storage_path'   => "${basedir}/storage",
                              'snapshots_path' => "${basedir}/snapshots"
               },
               'service' => {
                              'static_content_dir' => "${basedir}/static",
                              'host'               => $listen_address,
                              'http_port'          => 6333
               }
             }

  realize Apt::Source['publiq-tools']
  realize Group['qdrant']
  realize User['qdrant']

  unless $listen_address == '127.0.0.1' {
    include profiles::firewall::rules

    realize Firewall['400 accept qdrant traffic']
  }

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'qdrantdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/qdrant',
      fs_type      => 'ext4',
      owner        => 'qdrant',
      group        => 'qdrant',
      require      => [Group['qdrant'], User['qdrant']],
    }

    mount { "${basedir}/storage":
      ensure  => 'mounted',
      device  => '/data/qdrant',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['qdrantdata'], File["${basedir}/storage"]],
      before  => Package['qdrant']
    }
  }

  file { [$basedir, "${basedir}/storage"]:
    ensure  => 'directory',
    owner   => 'qdrant',
    group   => 'qdrant',
    require => [Group['qdrant'], User['qdrant']],
    before  => Package['qdrant']
  }

  package {'qdrant':
    ensure  => $version,
    require => [Group['qdrant'], User['qdrant']],
    notify  => Service['qdrant']
  }

  file { 'qdrant config':
    ensure  => 'file',
    path    => '/etc/qdrant/config.yaml',
    owner   => 'qdrant',
    group   => 'qdrant',
    content => stdlib::to_yaml($config),
    require => Package['qdrant'],
    notify  => Service['qdrant']
  }

  service { 'qdrant':
    enable => $service_status ? {
                'running' => true,
                'stopped' => false
              },
    ensure => $service_status
  }
}
