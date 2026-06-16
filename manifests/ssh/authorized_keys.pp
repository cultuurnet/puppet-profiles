class profiles::ssh::authorized_keys (
  Hash    $keys                              = {},
  Boolean $manage_admin_user_authorized_keys = true
) inherits ::profiles {

  if $facts['ec2_metadata'] {
    $admin_user = 'ubuntu'
  } else {
    $admin_user = 'vagrant'
  }

  $keys.each |$key, $attributes| {
    if $attributes['active'] {
      [$attributes['keys']].flatten.each |$index, $key_attributes | {
        if size([$attributes['keys']].flatten) == 1 {
          $key_title = $key
        } else {
          $key_number = $index + 1
          $key_title  = "${key} ${key_number}"
        }

        if $manage_admin_user_authorized_keys {
          @ssh_authorized_key { "${key_title} ${admin_user}":
            user => $admin_user,
            type => $key_attributes['type'],
            key  => $key_attributes['key'],
            tag  => $attributes['tags']
          }
        }

        @ssh_authorized_key { $key_title:
          user => slugify($key),
          type => $key_attributes['type'],
          key  => $key_attributes['key'],
          tag  => $attributes['tags']
        }
      }
    }
  }
}
