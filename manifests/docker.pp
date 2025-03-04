class profiles::docker (
  Boolean          $experimental   = false,
  Boolean          $schedule_prune = false,
  Boolean          $lvm            = false,
  Optional[String] $volume_group   = undef,
  Optional[String] $volume_size    = undef
) inherits ::profiles {

  $data_dir = '/var/lib/docker'

  realize Apt::Source['publiq-tools']
  realize Apt::Source['docker']

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'dockerdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/docker',
      fs_type      => 'ext4',
      owner        => 'root',
      group        => 'root'
    }

    mount { $data_dir:
      ensure  => 'mounted',
      device  => '/data/docker',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['dockerdata'], File[$data_dir]],
      before  => Class['docker']
    }
  }

  package { 'docker-compose':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  if $experimental {
    realize Package['qemu-user-static']
  }

  file { $data_dir:
    ensure => 'directory',
    before => Class['docker']
  }

  class { '::docker':
    use_upstream_package_source => false,
    docker_users                => [],
    extra_parameters            => [ "--experimental=${experimental}"],
    require                     => Apt::Source['docker']
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
    weekday     => '0',
    require     => Class['docker']
  }
}
