class profiles::backup::server (
  String                         $hostname,
  String                         $backupdir       = '/data/borgbackup',
  Boolean                        $lvm             = false,
  Optional[String]               $volume_group    = undef,
  Optional[String]               $volume_size     = undef,
  Enum['rsa', 'dsa']             $public_key_type = 'rsa',
  String                         $public_key
) inherits ::profiles {

  realize(Group['borgbackup'])
  realize(User['borgbackup'])

  package { 'borgbackup':
    ensure  => 'present'
  }

  @@sshkey { 'backup':
    name => $hostname,
    key  => $::sshrsakey,
    type => 'rsa'
  }

  ssh_authorized_key { 'backup':
    key     => $public_key,
    type    => $public_key_type,
    options => "command=\"borg serve --restrict-to-path ${backupdir}\"",
    user    => 'borgbackup',
    require => [Group['borgbackup'], User['borgbackup']]
  }

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'borgbackup':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => $backupdir,
      fs_type      => 'ext4',
      owner        => 'borgbackup',
      group        => 'borgbackup',
      require      => [Group['borgbackup'], User['borgbackup']],
    }
  } else {
    file { $backupdir:
      ensure  => 'directory',
      owner   => 'borgbackup',
      group   => 'borgbackup',
      require => [Group['borgbackup'], User['borgbackup']]
    }
  }
}
