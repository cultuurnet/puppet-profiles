class profiles::docker (
  Boolean $experimental   = false,
  Boolean $schedule_prune = false
) inherits ::profiles {

  realize Apt::Source['docker']

  if $experimental {
    realize Package['qemu-user-static']
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
