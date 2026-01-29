class profiles::ssh_authorized_keys(
  Hash $keys             = {},
  Optional[String] $user = undef
) inherits ::profiles {

  if $user {
    $admin_user = $user
  } else {
    if $facts['ec2_metadata'] {
      $admin_user = 'ubuntu'
    } else {
      $admin_user = 'vagrant'
    }
  }

  $keys.each | $key, $attributes| {
   [$attributes['keys']].flatten.each | $index, $key_attributes | {
      if size([$attributes['keys']].flatten) == 1 {
        $key_title = $key
      } else {
        $key_number = $index + 1
        $key_title  = "${key} ${key_number}"
      }

      @ssh_authorized_key { $key_title:
        user => $admin_user,
        type => $key_attributes['type'],
        key  => $key_attributes['key'],
        tag  => $attributes['tags']
      }
    }
  }
}
