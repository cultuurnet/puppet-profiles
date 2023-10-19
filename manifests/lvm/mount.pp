define profiles::lvm::mount (
  String           $volume_group,
  String           $size,
  String           $mountpoint,
  String           $fs_type       = 'ext4',
  Optional[String] $fs_options    = undef,
  Optional[String] $mount_options = undef,
  String           $owner         = 'root',
  String           $group         = 'root'
) {

  include ::profiles

  # We need to create all intermediate directories from /data to $mountpoint, this will provide a list
  $directory_tree = $mountpoint.split('/').map |$index, $dir| { $mountpoint.split('/')[0, $index + 1].join('/') }.filter |$item| { ! $item.empty } - [ '/data']

  unless $group == 'root' { realize Group[$group] }
  unless $owner == 'root' { realize User[$owner] }

  logical_volume { $title:
    ensure          => 'present',
    volume_group    => $volume_group,
    size            => $size,
    size_is_minsize => true,
    require         => Volume_group[$volume_group]
  }

  filesystem { "/dev/${volume_group}/${title}":
    ensure  => 'present',
    fs_type => $fs_type,
    options => $fs_options,
    require => Logical_volume[$title]
  }

  file { $directory_tree:
    ensure => 'directory',
    owner  => $owner,
    group  => $group
  }

  mount { $mountpoint:
    ensure  => 'mounted',
    device  => "/dev/${volume_group}/${title}",
    fstype  => $fs_type,
    options => $mount_options,
    atboot  => true,
    require => [Filesystem["/dev/${volume_group}/${title}"], File[$mountpoint]]
  }

  exec { "${mountpoint} ownership":
    command   => "chown ${owner}:${group} ${mountpoint}",
    logoutput => 'on_failure',
    path      => ['/usr/bin', '/bin'],
    onlyif    => "test '${owner}:${group}' != $(stat -c '%U:%G' ${mountpoint})",
    require   => Mount[$mountpoint]
  }
}
