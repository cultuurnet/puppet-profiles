class profiles::aptly (
  String                         $api_hostname,
  Optional[String]               $certificate       = undef,
  Hash                           $signing_keys      = {},
  Hash                           $trusted_keys      = {},
  String                         $version           = 'latest',
  String                         $data_dir          = '/var/aptly',
  Stdlib::Ipv4                   $api_bind          = '127.0.0.1',
  Stdlib::Port::Unprivileged     $api_port          = 8081,
  Hash                           $publish_endpoints = {},
  Hash                           $repositories      = {},
  Hash                           $mirrors           = {},
  Boolean                        $lvm               = false,
  Optional[String]               $volume_group      = undef,
  Optional[String]               $volume_size       = undef
) inherits ::profiles {

  $proxy_timeout = 3600
  $homedir       = '/home/aptly'

  realize Group['aptly']
  realize User['aptly']

  realize Package['graphviz']

  realize Apt::Key['aptly']
  realize Apt::Source['aptly']

  Apt::Key['aptly'] -> Apt::Source['aptly']

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'aptlydata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/aptly',
      fs_type      => 'ext4',
      owner        => 'aptly',
      group        => 'aptly',
      require      => [Group['aptly'], User['aptly']],
      before       => Class['::aptly'] 
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

  systemd::unit_file { 'aptly-api.service':
    content => template('profiles/aptly/aptly-api.service.erb'),
    enable  => true,
    active  => true,
    require => Class['aptly']
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

  $signing_keys.each |$name, $attributes| {
    gnupg_key { $name:
      ensure      => 'present',
      key_id      => $attributes['id'],
      user        => 'aptly',
      key_content => $attributes['content'],
      key_type    => 'private',
      require     => User['aptly']
    }
  }

  $trusted_keys.each |$name, $attributes| {
    @profiles::aptly::gpgkey { $name:
      * => $attributes
    }
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

  if !empty($mirrors) {
    # This is a somewhat hackish way to add trusted GPG keys to the aptly trustedkeys.gpg keyring.
    # The signature verification in aptly uses gpgv which defaults to this keyring for trusted keys.
    # The aptly commandline can override the default, but the API does not allow this.
    # Unfortunately, the gnupg puppet module only allows manipulating the default pubring.gpg and
    # secring.gpg keyrings. So, as a workaround, we use the gnupg_key puppet resource type to add the
    # public keys to pubring.gpg and symlink it to trustedkeys.gpg (the correct solution is enhancing
    # the gnupg_key type and provider to allow manipulating keys in other keyrings than the default,
    # but this would require far more work to implement).
    # As we don't import keys outside of puppet, the pubring.gpg only contains trusted keys.

    file { 'aptly trustedkeys.gpg':
      path   => "${homedir}/.gnupg/trustedkeys.gpg",
      ensure => 'link',
      target => "${homedir}/.gnupg/pubring.kbx",
      owner  => 'aptly',
      group  => 'aptly'
    }

    $mirrors.each |$name, $attributes| {
      [$attributes['keys']].flatten.each |$key| {
        realize Profiles::Aptly::Gpgkey[$key]

        Profiles::Aptly::Gpgkey[$key] -> File['aptly trustedkeys.gpg']
      }

      aptly::mirror { $name:
        location      => $attributes['location'],
        distribution  => $attributes['distribution'],
        components    => [$attributes['components']].flatten,
        architectures => ['amd64'],
        update        => false,
        keyring       => "${homedir}/.gnupg/trustedkeys.gpg",
        require       => File['aptly trustedkeys.gpg']
      }
    }
  }
}
