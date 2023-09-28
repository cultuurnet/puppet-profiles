define profiles::nfs::mount (
  String           $mountpoint,
  String           $fstype        = 'nfs4',
  Optional[String] $mount_options = undef,
  String           $owner         = 'root',
  String           $group         = 'root',
  Boolean          $atboot        = true
) {

  include ::profiles
  include ::profiles::nfs

  # We need to create all intermediate directories from /data to $mountpoint, this will provide a list
  $directory_tree = $mountpoint.split('/').map |$index, $dir| { $mountpoint.split('/')[0, $index + 1].join('/') }.filter |$item| { ! $item.empty }

  unless $group == 'root' { realize Group[$group] }
  unless $owner == 'root' { realize User[$owner] }

  mount { $mountpoint:
    ensure  => 'mounted',
    device  => $title,
    fstype  => $fstype,
    options => $mount_options,
    atboot  => $atboot
  }

  exec { "${mountpoint} ownership":
    command   => "chown ${owner}:${group} ${mountpoint}",
    logoutput => 'on_failure',
    path      => ['/usr/bin', '/bin'],
    onlyif    => "test '${owner}:${group}' != $(stat -c '%U:%G' ${mountpoint})",
    require   => Mount[$mountpoint]
  }
}
