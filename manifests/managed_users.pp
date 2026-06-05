class profiles::managed_users inherits ::profiles {

  $ssh_users = lookup('profiles::ssh_users', Hash, 'first', {})
  $ssh_users.each |$_name, $attributes| {
    if $attributes['create_user'] {
      $username = $attributes['username']

      profiles::managed_user { $username:
        keys => $attributes['keys'],
        uid  => $attributes['uid'],
        sudo => $attributes['sudo']
      }
    }
  }
}
