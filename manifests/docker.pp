class profiles::docker (
  Variant[String, Array[String]] $users = []
) inherits ::profiles {

  realize Apt::Source['docker']
  realize Group['docker']

  [$users].flatten.each |$user| {
    realize User[$user]

    exec { "Add user ${user} to docker group":
      command => "usermod -aG docker ${user}",
      path    => [ '/usr/sbin', '/usr/bin'],
      unless  => "getent group docker | cut -d ':' -f 4 | tr ',' '\\n' | grep -q ${user}",
      require => [ Group['docker'], User[$user]]
    }

    User[$user] -> Class['docker']
  }

  class { '::docker':
    use_upstream_package_source => false,
    docker_users                => [],
    require                     => [ Apt::Source['docker'], Group['docker']]
  }
}
