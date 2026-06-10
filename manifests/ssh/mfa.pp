class profiles::ssh::mfa (
  Hash                           $users         = lookup('profiles::ssh::authorized_keys', Hash, 'first', {}),
  Variant[String, Array[String]] $user_tags     = lookup(
    'profiles::ssh::ssh_authorized_keys_tags',
    Variant[String, Array[String]],
    'first',
    []
  ),
  String                         $mfa_directory = '/etc/puppetlabs/code/data/mfa'
) inherits ::profiles {

  $user_tags_array = [$user_tags].flatten

  $users.each |String $user, Hash $attributes| {
    $tags = $attributes['tags'] ? {
      undef   => [],
      default => [$attributes['tags']].flatten
    }

    $configured = $tags.any |String $tag| { $tag in $user_tags_array }

    if $configured and $attributes['active'] != false {
      $username = slugify($user)
      $config   = "${mfa_directory}/${username}.conf"

      if find_file($config) {
        file { "/home/${username}/.google_authenticator":
          ensure    => 'file',
          owner     => $username,
          group     => $username,
          mode      => '0600',
          content   => file($config),
          show_diff => false,
          require   => User[$username]
        }
      }
    }
  }
}
