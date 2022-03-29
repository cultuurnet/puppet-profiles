class profiles::docker (
  Variant[String, Array[String]] $users = []
) inherits ::profiles {

  [$users].flatten.each |$user| {
    realize User[$user]

    User[$user] -> Package['docker.io']
    #User[$user] -> Class['docker']
  }

  Group <| title == 'docker' |> { members +> [$users].flatten }

  package { 'docker.io':
    ensure  => 'present',
    require => Group['docker']
  }

  #class { '::docker':
  #  use_upstream_package_source => false,
  #  docker_users                => [],
  #  require                     => Group['docker']
  #}
}
