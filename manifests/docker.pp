class profiles::docker (
  Boolean $experimental = false
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
}
