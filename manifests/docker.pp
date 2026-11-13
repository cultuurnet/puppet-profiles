class profiles::docker (
  Boolean                        $experimental           = false,
  Boolean                        $schedule_prune         = false,
  Boolean                        $lvm                    = false,
  Optional[String]               $volume_group           = undef,
  Optional[String]               $docker_volume_size     = undef,
  Optional[String]               $containerd_volume_size = undef,
  Variant[String, Array[String]] $ecr_registries         = [],
  Variant[String, Array[String]] $ecr_users              = [],
  Optional[String]               $log_driver             = 'json-file',
  Array[String]                  $log_opt                = ['max-size=50m', 'max-file=5']
) inherits ::profiles {

  $docker_data_dir = '/var/lib/docker'
  $containerd_data_dir = '/var/lib/containerd'

  realize Apt::Source['docker']

  if $lvm {
    unless ($volume_group and $docker_volume_size and $containerd_volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group', 'docker_volume_size' and 'containerd_volume_size'")
    }

    profiles::lvm::mount { 'dockerdata':
      volume_group => $volume_group,
      size         => $docker_volume_size,
      mountpoint   => '/data/docker',
      fs_type      => 'ext4',
      owner        => 'root',
      group        => 'root'
    }

    profiles::lvm::mount { 'containerddata':
      volume_group => $volume_group,
      size         => $containerd_volume_size,
      mountpoint   => '/data/containerd',
      fs_type      => 'ext4',
      owner        => 'root',
      group        => 'root'
    }

    mount { $docker_data_dir:
      ensure  => 'mounted',
      device  => '/data/docker',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['dockerdata'], File[$docker_data_dir]],
      before  => Class['::docker']
    }

    mount { $containerd_data_dir:
      ensure  => 'mounted',
      device  => '/data/containerd',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['containerddata'], File[$containerd_data_dir]],
      before  => Class['::docker']
    }
  }

  if $experimental {
    realize Package['qemu-user-static']
  }

  file { $docker_data_dir:
    ensure => 'directory',
    before => Class['::docker']
  }

  file { $containerd_data_dir:
    ensure => 'directory',
    before => Class['::docker']
  }

  class { '::docker':
    use_upstream_package_source => false,
    docker_users                => [],
    extra_parameters            => [ "--experimental=${experimental}"],
    log_driver                  => $log_driver,
    log_opt                     => $log_opt,
    require                     => Apt::Source['docker']
  }

  @profiles::jenkins::node_labels { 'docker':
    content => 'docker'
  }

  class { 'profiles::docker::ecr_login':
    registries => $ecr_registries,
    users      => $ecr_users,
    require    => Class['::docker']
  }

  collectd::plugin::filter::rule { 'ignore_docker_mounts':
    chain => 'PostCache'
  }

  collectd::plugin::filter::match { 'df_plugin_docker_mounts':
    chain   => 'PostCache',
    rule    => 'ignore_docker_mounts',
    plugin  => 'regex',
    options => {
                 'Plugin'         => '^df$',
                 'PluginInstance' => '^(data-docker-tmp|var-lib-docker-tmp|run-docker).*'
               }
  }

  collectd::plugin::filter::target { 'ignore_docker_mounts':
    chain  => 'PostCache',
    rule   => 'ignore_docker_mounts',
    plugin => 'stop'
  }

  cron { 'docker system prune':
    ensure      => $schedule_prune ? {
                     true  => 'present',
                     false => 'absent'
                   },
    command     => '/usr/bin/docker system prune -f -a --volumes',
    environment => ['MAILTO=infra+cron@publiq.be'],
    hour        => '3',
    minute      => '30',
    weekday     => ['0', '2', '4', '6'],
    require     => Class['::docker']
  }
}
