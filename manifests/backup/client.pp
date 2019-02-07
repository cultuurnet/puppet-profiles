class profiles::backup::client (
  String $private_key,
  Hash   $configuration = {}
)
{
  contain ::profiles

  Sshkey <<| title == 'backup' |>>

  class { 'borgbackup':
    configurations => $configuration
  }

  file { '/root/.ssh':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700'
  }

  file { '/root/.ssh/backup_rsa':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => $private_key
  }
}
