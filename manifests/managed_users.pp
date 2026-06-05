class profiles::managed_users(
  Variant[String, Array[String]] $tags = lookup('profiles::ssh::ssh_authorized_keys_tags', Variant[String, Array[String]], 'first', [])
) inherits ::profiles {

  $ssh_users = lookup('profiles::ssh_users', Hash, 'first', {})

  $ssh_users.each |$_name, $attributes| {
    $user_tags = [$attributes['tags']].flatten
    $matching_tags = $user_tags.filter |$tag| { $tag in [$tags].flatten }

    if $attributes['create_user'] and ! $matching_tags.empty {
      $username = $attributes['username']

      profiles::managed_user { $username:
        keys => $attributes['keys'],
        uid  => $attributes['uid'],
        sudo => $attributes['sudo']
      }
    }
  }
}
