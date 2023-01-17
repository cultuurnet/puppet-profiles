class profiles::aptly (
  String                         $api_hostname,
  Optional[String]               $certificate       = undef,
  Hash                           $signing_keys      = {},
  String                         $version           = 'latest',
  String                         $data_dir          = '/var/aptly',
  Stdlib::Ipv4                   $api_bind          = '127.0.0.1',
  Stdlib::Port::Unprivileged     $api_port          = 8081,
  Hash                           $publish_endpoints = {},
  Hash                           $repositories      = {},
  Hash                           $mirrors           = {}
) inherits ::profiles {

  realize Group['aptly']
  realize User['aptly']

  realize Package['graphviz']

  realize Apt::Key['aptly']
  realize Apt::Source['aptly']

  Apt::Key['aptly'] -> Apt::Source['aptly']

  $proxy_timeout = 3600

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
    require              => [ Apt::Source['aptly'], User['aptly']],
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

  if $certificate {
    profiles::apache::vhost::redirect { "http://${api_hostname}":
      destination => "https://${api_hostname}"
    }

    profiles::apache::vhost::reverse_proxy { "https://${api_hostname}":
      certificate  => $certificate,
      destination  => "http://${api_bind}:${api_port}/",
      proxy_params => { 'timeout' => $proxy_timeout }
    }
  } else {
    profiles::apache::vhost::reverse_proxy { "http://${api_hostname}":
      destination  => "http://${api_bind}:${api_port}/",
      proxy_params => { 'timeout' => $proxy_timeout }
    }
  }

  cron { 'aptly db cleanup daily':
    command     => '/usr/bin/aptly db cleanup',
    environment => [ 'MAILTO=infra@publiq.be'],
    user        => 'aptly',
    hour        => '4',
    minute      => '0',
    require     => [ Class['aptly'], User['aptly']]
  }

  $repositories.each |$repo, $attributes| {
    $archive = $attributes['archive']

    aptly::repo { $repo:
      default_component => 'main'
    }

    if $archive {
      aptly::repo { "${repo}-archive":
        default_component => 'main'
      }
    }
  }

  $mirrors.each |$name, $attributes| {
    realize Apt::Key[$attributes['key']]

    aptly::mirror { $name:
      location      => $attributes['location'],
      distribution  => $attributes['distribution'],
      components    => [$attributes['components']].flatten,
      architectures => ['amd64'],
      update        => false,
      require       => Apt::Key[$attributes['key']]
    }
  }
}
