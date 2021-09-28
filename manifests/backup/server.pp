class profiles::backup::server (
  String                         $hostname,
  Variant[String, Array[String]] $physical_volumes,
  String                         $backupdir,
  String                         $public_key,
  Enum['rsa', 'dsa']             $public_key_type = 'rsa',
  String                         $size = '1G'
) inherits ::profiles {

  include ::profiles::groups
  include ::profiles::users

  realize(Group['borgbackup'])
  realize(User['borgbackup'])

  @@sshkey { 'backup':
    name => $hostname,
    key  => $::sshrsakey,
    type => 'rsa'
  }

  ssh_authorized_key { 'backup':
    key     => $public_key,
    type    => $public_key_type,
    options => "command=\"borg serve --restrict-to-path ${backupdir}\"",
    user    => 'borgbackup'
  }

  any2array($physical_volumes).each |$physical_volume| {
    physical_volume { $physical_volume:
      ensure => present
    }
  }

  volume_group { 'backupvg':
    ensure           => present,
    physical_volumes => $physical_volumes,
  }

  logical_volume { 'backup':
    ensure       => present,
    volume_group => 'backupvg',
    size         => $size,
  }

  filesystem { '/dev/backupvg/backup':
    ensure  => present,
    fs_type => 'ext4'
  }

  exec { "create ${backupdir}":
    command => "install -o borgbackup -g borgbackup -d ${backupdir}",
    unless  => "test -d ${backupdir}",
    path    => '/usr/bin:/usr/sbin:/bin'
  }

  mount { $backupdir:
    ensure  => 'mounted',
    device  => '/dev/backupvg/backup',
    options => 'defaults',
    atboot  => true,
    fstype  => 'ext4'
  }

  file { $backupdir:
    ensure => 'directory',
    owner  => 'borgbackup',
    group  => 'borgbackup'
  }

  User['borgbackup'] -> Ssh_authorized_key['backup']
  User['borgbackup'] -> Exec["create ${backupdir}"]
  Exec["create ${backupdir}"] -> Mount[$backupdir]
  Filesystem['/dev/backupvg/backup'] -> Mount[$backupdir]
  Mount[$backupdir] -> File[$backupdir]
}
