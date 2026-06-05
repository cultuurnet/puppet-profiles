define profiles::managed_user (
  Variant[Hash, Array[Hash]]     $keys,
  Integer                        $uid,
  Boolean                        $sudo = false,
  Variant[String, Array[String]] $tags = []
) {
  $groups = $sudo ? {
    true    => ['managed_users', 'sudo'],
    default => ['managed_users']
  }

  group { $title:
    ensure => 'present',
    tag    => $tags
  }

  user { $title:
    ensure         => 'present',
    gid            => $title,
    groups         => $groups,
    home           => "/home/${title}",
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/bin/bash',
    uid            => $uid,
    tag            => $tags,
    require        => [Group['managed_users'], Group[$title]]
  }

  [$keys].flatten.each |$index, $key_attributes| {
    if size([$keys].flatten) == 1 {
      $key_title = $title
    } else {
      $key_number = $index + 1
      $key_title  = "${title} authorized_key ${key_number}"
    }

    ssh_authorized_key { $key_title:
      user    => $title,
      type    => $key_attributes['type'],
      key     => $key_attributes['key'],
      tag     => $tags,
      require => User[$title]
    }
  }
}
