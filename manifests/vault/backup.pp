class profiles::vault::backup (
  Boolean          $lvm            = false,
  Optional[String] $volume_group   = undef,
  Optional[String] $volume_size    = undef,
  Integer          $retention_days = 7
) inherits ::profiles {

  $mtime = $retention_days - 1

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'vaultbackup':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/backup/vault',
      fs_type      => 'ext4'
    }
  } else {

    realize File['/data']
    realize File['/data/backup']

    file { '/data/backup/vault':
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File['/data/backup'],
    }
  }

  file { ['/data/backup/vault/current', '/data/backup/vault/archive']:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/data/backup/vault'],
  }

  file { 'vaultbackup':
    ensure => 'file',
    path   => '/usr/local/bin/vaultbackup',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profiles/vault/vaultbackup'
  }

  cron { 'backup vault':
    command     => '/usr/local/bin/vaultbackup',
    environment => ['MAILTO=infra+cron@publiq.be'],
    user        => 'root',
    hour        => '0',
    minute      => '15',
    require     => File['vaultbackup']
  }

  cron { "Cleanup old vault backups":
    command     => "/usr/bin/find /data/backup/vault/archive -type f -mtime +${mtime} -delete",
    environment => ['MAILTO=infra+cron@publiq.be'],
    user        => 'root',
    hour        => '2',
    minute      => '15',
    require     => File['/data/backup/vault/archive']
  }
}
