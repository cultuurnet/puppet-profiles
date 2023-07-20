class profiles::mysql::server (
  Boolean          $lvm            = false,
  Optional[String] $volume_group   = undef,
  Optional[String] $volume_size    = undef,
  Integer          $max_open_files = 1024
) inherits ::profiles {

  realize Group['mysql']
  realize User['mysql']


  if $lvm {

    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'mysqldata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/mysql',
      fs_type      => 'ext4',
      owner        => 'mysql',
      group        => 'mysql',
      require      => [Group['mysql'], User['mysql']],
      before       => Class['mysql::server']
    }

    file { '/var/lib/mysql':
      ensure  => 'link',
      target  => '/data/mysql',
      force   => true,
      owner   => 'mysql',
      group   => 'mysql',
      require => [File['/var/lib/mysql'], Profiles::Lvm::Mount['mysqldata']],
      before  => Class['mysql::server']
    }
  }

  systemd::dropin_file { 'mysql override.conf':
    unit          => 'mysql.service',
    filename      => 'override.conf',
    content       => "[Service]\nLimitNOFILE=${max_open_files}"
  }

  include ::mysql::server

  Group['mysql'] -> Class['mysql::server']
  User['mysql'] -> Class['mysql::server']
  Systemd::Dropin_file['mysql override.conf'] -> Class['mysql::server']
  Systemd::Dropin_file['mysql override.conf'] ~> Class['mysql::server::service']
}
