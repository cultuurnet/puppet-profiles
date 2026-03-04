class profiles::docker::ecr_login (
  Variant[String, Array[String]] $registries = [],
  Variant[String, Array[String]] $users      = []
) inherits ::profiles {

  realize Package['amazon-ecr-credential-helper']

  $config_content = { "credHelpers" => [$registries].flatten.reduce({}) |Hash $all, String $registry| { $all + { $registry => 'ecr-login' } } }

  [$users].flatten.each |$user| {
    case $user {
      'root': {
        $homedir = '/root'
      }
      'jenkins': {
        $homedir = '/var/lib/jenkins'

        realize Group['jenkins']
        realize User['jenkins']
      }
      default: {
        $homedir = "/home/${user}"

        realize Group[$user]
        realize User[$user]
      }
    }

    file { "${user} docker config directory":
      ensure => 'directory',
      path   => "${homedir}/.docker",
      owner  => $user,
      group  => $user
    }

    file { "${user} docker config":
      ensure  => 'file',
      path    => "${homedir}/.docker/config.json",
      owner   => $user,
      group   => $user,
      content => to_json($config_content),
      require => File["${user} docker config directory"]
    }
  }
}
