class profiles::docker (
  Variant[String, Array[String]] $users        = [],
  Boolean                        $experimental = false
) inherits ::profiles {

  realize Apt::Source['docker']
  realize Group['docker']

  [$users].flatten.each |$user| {
    realize User[$user]

    exec { "Add user ${user} to docker group":
      command => "usermod -aG docker ${user}",
      path    => [ '/usr/sbin', '/usr/bin', '/bin'],
      unless  => "getent group docker | cut -d ':' -f 4 | tr ',' '\\n' | grep -q '^${user}$'",
      require => [ Group['docker'], User[$user]]
    }

    User[$user] -> Class['docker']
  }

  class { '::docker':
    use_upstream_package_source => false,
    docker_users                => [],
    extra_parameters            => [ "--experimental=${experimental}"],
    require                     => [ Apt::Source['docker'], Group['docker']]
  }

  if $experimental {
    realize Package['qemu-user-static']
  }
}
