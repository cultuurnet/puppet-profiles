class profiles::vault (
  String                     $version         = 'latest',
  Boolean                    $auto_unseal     = false,
  Optional[String]           $certname        = undef,
  Enum['running', 'stopped'] $service_status  = 'running',
  String                     $service_address = '127.0.0.1',
  Integer[1]                 $key_threshold   = 1,
  Variant[Hash,Array[Hash]]  $gpg_keys        = [],
  Boolean                    $lvm             = false,
  Optional[String]           $volume_group    = undef,
  Optional[String]           $volume_size     = undef
) inherits ::profiles {

  if $auto_unseal {
    if $key_threshold > 1 { fail('with auto_unseal, key threshold cannot be higher than 1') }
  } else {
    if empty($gpg_keys) { fail('without auto_unseal, at least one GPG key has to be provided') }
    if (length([$gpg_keys].flatten) > 1 and $key_threshold < 2) { fail('with multiple key shares, key threshold must be higher than 1') }
  }

  include ::profiles::firewall::rules

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'vaultdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/vault',
      fs_type      => 'ext4',
      owner        => 'vault',
      group        => 'vault',
      require      => [Group['vault'], User['vault']]
    }

    file { '/opt/vault':
      ensure  => 'directory',
      owner   => 'vault',
      group   => 'vault',
      require => [Group['vault'], User['vault']]
    }

    mount { '/opt/vault':
      ensure  => 'mounted',
      device  => '/data/vault',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['vaultdata'], File['/opt/vault']],
      before  => Class['profiles::vault::install']
    }
  }

  if !($service_address == '127.0.0.1') {
    realize Firewall['400 accept vault traffic']
  }

  class { 'profiles::vault::install':
    version => $version,
    notify  => Class['profiles::vault::service']
  }

  if $certname {
    class { 'profiles::vault::certificate':
      certname => $certname,
      require  => Class['profiles::vault::install'],
      before   => Class['profiles::vault::configuration']
    }
  }

  class { 'profiles::vault::configuration':
    certname        => $certname,
    service_address => $service_address,
    require         => Class['profiles::vault::install'],
    notify          => Class['profiles::vault::service']
  }

  class { 'profiles::vault::service':
    service_status => $service_status
  }

  if $service_status == 'running' {
    unless $facts['vault_initialized'] {
      class { 'profiles::vault::init':
        auto_unseal   => $auto_unseal,
        key_threshold => $key_threshold,
        gpg_keys      => $gpg_keys,
        require       => Class['profiles::vault::service'],
        before        => Class['profiles::vault::seal']
      }
    }

    class { 'profiles::vault::seal':
      auto_unseal => $auto_unseal,
      require     => Class['profiles::vault::service']
    }

    if $auto_unseal {
      class { 'profiles::vault::authentication':
        require => Class['profiles::vault::seal']
      }

      class { 'profiles::vault::secrets_engines':
        require => Class['profiles::vault::seal']
      }

      class { 'profiles::vault::policies':
        require => [Class['profiles::vault::secrets_engines'], Class['profiles::vault::authentication']]
      }
    }
  }
}
