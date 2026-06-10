class profiles::ssh::mfa (
  Variant[Hash, Array[Hash]]     $authorized_keys      = {},
  Variant[String, Array[String]] $authorized_keys_tags = [],
  String                         $mfa_directory        = '/etc/puppetlabs/code/data/mfa'
) inherits ::profiles {

  $authorized_keys_tags_array = [$authorized_keys_tags].flatten

  $authorized_keys.each |String $user, Hash $attributes| {
    $tags = $attributes['tags'] ? {
      undef   => [],
      default => [$attributes['tags']].flatten
    }

    $configured = $tags.any |String $tag| { $tag in $authorized_keys_tags_array }

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
