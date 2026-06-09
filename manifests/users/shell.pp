define profiles::users::shell (
  Integer[5000]                  $uid,
  Boolean                        $active = true,
  Boolean                        $admin  = false,
  Variant[String, Array[String]] $tags   = []
) {

  $username = slugify($title)
  $ensure   = $active ? {
                true  => 'present',
                false => 'absent'
              }

  group { $username:
    ensure => $ensure,
    gid    => $uid
  }

  user { $username:
    ensure         => $ensure,
    uid            => $uid,
    gid            => $username,
    groups         => $admin ? {
                        true  => ['sudo'],
                        false => []
                      },
    home           => "/home/${username}",
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/bin/bash'
  }
}
