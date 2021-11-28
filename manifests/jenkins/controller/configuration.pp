class profiles::jenkins::controller::configuration(
  Stdlib::Httpurl            $url,
  String                     $admin_password,
  Variant[Hash, Array[Hash]] $credentials    = []
) inherits ::profiles {

  $string_credentials      = [$credentials].flatten.filter |$credential| { $credential['type'] == 'string' }
  $private_key_credentials = [$credentials].flatten.filter |$credential| { $credential['type'] == 'private_key' }

  profiles::jenkins::plugin { 'swarm': }
  profiles::jenkins::plugin { 'git':
    configuration => {
                       'user_name'  => 'publiq Jenkins',
                       'user_email' => 'jenkins@publiq.be'
                     },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }
  profiles::jenkins::plugin { 'configuration-as-code':
    configuration => {
                       'url'            => $url,
                       'admin_password' => $admin_password
                     },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }
  profiles::jenkins::plugin { 'plain-credentials':
    configuration => $string_credentials,
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }
  profiles::jenkins::plugin { 'ssh-credentials':
    configuration => $private_key_credentials,
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  class { '::profiles::jenkins::controller::configuration::reload': }

  class { '::profiles::jenkins::cli::credentials':
    user     => 'admin',
    password => $admin_password,
    require  => Class['profiles::jenkins::controller::configuration::reload']
  }
}
