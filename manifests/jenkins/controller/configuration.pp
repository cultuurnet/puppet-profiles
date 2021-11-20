class profiles::jenkins::controller::configuration(
  Stdlib::Httpurl $url
) inherits ::profiles {

  profiles::jenkins::plugin { 'swarm': }
  profiles::jenkins::plugin { 'configuration-as-code':
    configuration => {
                       'url'        => $url
                     }
  }

  class { '::profiles::jenkins::controller::configuration::reload':
    require => Profiles::Jenkins::Plugin['configuration-as-code']
  }
}
