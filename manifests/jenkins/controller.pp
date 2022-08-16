class profiles::jenkins::controller (
  # Stdlib::Httpurl         $url,
  String                    $url,
  String                    $admin_password,
  String                    $version                      = 'latest',
  Optional[String]          $certificate                  = undef,
  # Optional[Stdlib::Httpurl] $docker_registry_url        = undef,
  Optional[String]          $docker_registry_url          = undef,
  Optional[String]          $docker_registry_credentialid = undef,
  Variant[Array,Hash]       $credentials                  = [],
  Variant[Array,Hash]       $global_libraries             = [],
  Variant[Array,Hash]       $pipelines                    = [],
  Variant[Array,Hash]       $users                        = []
) inherits ::profiles {

  include ::profiles::java

  $hostname   = split($url, '/')[2]

  class { '::profiles::jenkins::controller::install':
    version => $version,
    require => Class['profiles::java'],
    notify  => Class['profiles::jenkins::controller::service']
  }

  class { '::profiles::jenkins::controller::service': }

  class { '::profiles::jenkins::cli':
    version        => $version,
    controller_url => $url
  }

  class { '::profiles::jenkins::controller::configuration':
    url                          => $url,
    admin_password               => $admin_password,
    docker_registry_url          => $docker_registry_url,
    docker_registry_credentialid => $docker_registry_credentialid,
    credentials                  => $credentials,
    global_libraries             => $global_libraries,
    pipelines                    => $pipelines,
    users                        => $users,
    require                      => [ Class['profiles::jenkins::controller::service'], Class['profiles::jenkins::cli']]
  }

  if $certificate {
    profiles::apache::vhost::redirect { "http://${hostname}":
      destination => "https://${hostname}"
    }

    profiles::apache::vhost::reverse_proxy { "https://${hostname}":
      destination           => 'http://127.0.0.1:8080/',
      certificate           => $certificate,
      preserve_host         => true,
      allow_encoded_slashes => 'nodecode',
      proxy_keywords        => 'nocanon',
      support_websockets    => true
    }

    Profiles::Apache::Vhost::Reverse_proxy["https://${hostname}"] -> Class['profiles::jenkins::cli']
  } else {
    profiles::apache::vhost::reverse_proxy { "http://${hostname}":
      destination           => 'http://127.0.0.1:8080/',
      preserve_host         => true,
      allow_encoded_slashes => 'nodecode',
      proxy_keywords        => 'nocanon',
      support_websockets    => true
    }

    Profiles::Apache::Vhost::Reverse_proxy["http://${hostname}"] -> Class['profiles::jenkins::cli']
  }
}
