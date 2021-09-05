class profiles::aptly (
  String                         $api_hostname,
  String                         $certificate,
  Hash                           $signing_keys      = {},
  String                         $version           = 'latest',
  String                         $data_dir          = '/var/aptly',
  Stdlib::Ipv4                   $api_bind          = '127.0.0.1',
  Stdlib::Port::Unprivileged     $api_port          = 8081,
  Hash                           $publish_endpoints = {},
  Variant[String, Array[String]] $repositories      = [],
  Hash                           $mirrors           = {}
) {

  contain ::profiles

  include ::profiles::users
  include ::profiles::groups
  include ::profiles::packages
  include ::profiles::apt::updates

  realize Group['aptly']
  realize User['aptly']

  realize Package['graphviz']

  realize Profiles::Apt::Update['aptly']

  $signing_keys.each |$name, $attributes| {
    gnupg_key { $name:
      ensure     => 'present',
      key_id     => $attributes['id'],
      user       => 'aptly',
      key_source => $attributes['source'],
      key_type   => 'private',
      require    => User['aptly']
    }
  }

  class { '::aptly':
    version              => $version,
    install_repo         => false,
    manage_user          => false,
    root_dir             => $data_dir,
    enable_service       => false,
    enable_api           => true,
    api_bind             => $api_bind,
    api_port             => $api_port,
    api_nolock           => true,
    require              => [ Profiles::Apt::Update['aptly'], User['aptly']],
    s3_publish_endpoints => $publish_endpoints
  }

  if versioncmp( $facts['os']['release']['major'], '16.04') >= 0 {
    systemd::unit_file { 'aptly-api.service':
      content => template('profiles/aptly/aptly-api.service.erb'),
      enable  => true,
      active  => true,
      require => Class['aptly']
    }
  }

  profiles::apache::vhost::redirect { "http://${api_hostname}":
    destination => "https://${api_hostname}"
  }

  profiles::apache::vhost::reverse_proxy { "https://${api_hostname}":
    certificate => $certificate,
    destination => "http://${api_bind}:${api_port}/"
  }

  [$repositories].flatten.each |$repo| {
    aptly::repo { $repo:
      default_component => 'main'
    }
  }

  $mirrors.each |$name, $attributes| {
    aptly::mirror { $name:
      location      => $attributes['location'],
      distribution  => $attributes['distribution'],
      components    => $attributes['components'],
      architectures => $attributes['architectures']
    }
  }
}
