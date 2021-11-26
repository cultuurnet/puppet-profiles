class profiles::jenkins::controller::configuration(
  Stdlib::Httpurl $url,
  String          $admin_password
) inherits ::profiles {

  profiles::jenkins::plugin { 'swarm': }
  profiles::jenkins::plugin { 'configuration-as-code':
    configuration => {
                       'url'            => $url,
                       'admin_password' => $admin_password
                     },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  class { '::profiles::jenkins::controller::configuration::reload': }

  class { '::profiles::jenkins::cli::credentials':
    user     => 'admin',
    password => $admin_password,
    require  => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'plain-credentials':
    configuration => {
                       'credentials' => $credentials.filter |$credential| { $credential['type'] == 'string' }
                     },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }
}
