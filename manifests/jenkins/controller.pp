class profiles::jenkins::controller (
  Stdlib::Httpurl $url,
  String          $admin_password,
  String          $certificate,
  String          $version     = 'latest'
) inherits ::profiles {

  include ::profiles::java

  $hostname   = split($url, '/')[2]

  class { '::profiles::jenkins::controller::install':
    version => $version,
    require => Class['profiles::java'],
    notify  => Class['profiles::jenkins::controller::service']
  }

  class { '::profiles::jenkins::controller::configuration':
    url            => $url,
    admin_password => $admin_password
  }

  class { '::profiles::jenkins::controller::service': }

  class { '::profiles::jenkins::cli':
    version        => $version,
    controller_url => $url
  }

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
}
