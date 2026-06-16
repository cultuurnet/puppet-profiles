define profiles::users::shell (
  Integer[5000]                  $uid,
  Optional[Boolean]              $active = false,
  Optional[Boolean]              $admin  = false,
  Optional[Boolean]              $mfa    = true,
  Optional[Boolean]              $mfa_enforced = false,
  Optional[String]               $mfa_config = undef,
  Variant[String, Array[String]] $tags   = []
) {

  $username       = slugify($title)
  $mfa_configured = $mfa and $mfa_config != undef
  $base_groups    = $admin ? {
                    true  => ['sudo'],
                    false => []
                  }
  $mfa_required   = $mfa and ($mfa_enforced or $mfa_configured)
  $groups         = $mfa_required ? {
                    true  => $base_groups + ['mfa_users'],
                    false => $base_groups
                  }
  $ensure         = $active ? {
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
    groups         => $groups,
    home           => "/home/${username}",
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/bin/bash'
  }

  if $mfa_configured {
    file { "/home/${username}/.google_authenticator":
      ensure    => 'file',
      owner     => $username,
      group     => $username,
      mode      => '0400',
      content   => file($mfa_config),
      show_diff => false,
      require   => User[$username]
    }
  } else {
    file { "/home/${username}/.google_authenticator":
      ensure => 'absent'
    }
  }
}
