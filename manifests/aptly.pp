class profiles::aptly (
  String                         $api_hostname,
  Optional[String]               $certificate       = undef,
  Hash                           $signing_keys      = {},
  Hash                           $trusted_keys      = {},
  String                         $version           = 'latest',
  Optional[String]               $gpg_passphrase    = undef,
  Stdlib::IP::Address::V4        $api_bind          = '127.0.0.1',
  Stdlib::Port::Unprivileged     $api_port          = 8081,
  Hash                           $publish_endpoints = {},
  Hash                           $repositories      = {},
  Hash                           $mirrors           = {},
  Variant[String, Array[String]] $architectures     = 'amd64',
  Boolean                        $lvm               = false,
  Optional[String]               $volume_group      = undef,
  Optional[String]               $volume_size       = undef
) inherits ::profiles {

  $data_dir      = '/var/aptly'
  $home_dir      = '/home/aptly'
  $proxy_timeout = 7200

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

    mount { $data_dir:
      ensure  => 'mounted',
      device  => '/data/aptly',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['aptlydata'], Class['::aptly']]
    }
  }

  class { '::aptly':
    package_ensure => $version,
    repo           => false,
    user           => 'aptly',
    config         => {
                        'rootDir'            => $data_dir,
                        'architectures'      => 'amd64',
                        'S3PublishEndpoints' => $publish_endpoints
                      },
    require        => [Apt::Source['aptly'], User['aptly']],
  }

  class { '::aptly::api':
    user                => 'aptly',
    group               => 'aptly',
    listen              => "${api_bind}:${api_port}",
    enable_cli_and_http => true,
    require             => [Class['::aptly'], Group['aptly'], User['aptly']]
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

  file { 'version restore script':
    path    => '/usr/local/sbin/restore-versions',
    ensure  => 'file',
    mode    => '0755',
    content => template('profiles/aptly/restore-versions.erb')
  }

  cron { 'aptly db cleanup daily':
    command     => '/usr/bin/aptly db cleanup',
    environment => ['MAILTO=infra+cron@publiq.be'],
    user        => 'aptly',
    hour        => '4',
    minute      => '0',
    require     => [Class['aptly'], User['aptly']]
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
      component => 'main'
    }

    if $archive {
      aptly::repo { "${repo}-archive":
        component => 'main',
        require   => Aptly::Repo[$repo]
      }
    }

    if $lvm {
      Mount[$data_dir] -> Aptly::Repo[$repo]
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
      path   => "${home_dir}/.gnupg/trustedkeys.gpg",
      ensure => 'link',
      target => "${home_dir}/.gnupg/pubring.kbx",
      owner  => 'aptly',
      group  => 'aptly'
    }

    $mirrors.each |$mirror, $attributes| {
      [$attributes['keys']].flatten.each |$key| {
        realize Profiles::Aptly::Gpgkey[$key]

        Profiles::Aptly::Gpgkey[$key] -> File['aptly trustedkeys.gpg']
      }

      aptly::mirror { $mirror:
        location      => $attributes['location'],
        release       => $attributes['distribution'],
        repos         => [$attributes['components']].flatten,
        architectures => [$attributes['architectures']].flatten,
        keyring       => "${home_dir}/.gnupg/trustedkeys.gpg",
        require       => File['aptly trustedkeys.gpg']
      }

      if $lvm {
        Mount[$data_dir] -> Aptly::Mirror[$mirror]
      }
    }
  }
}
