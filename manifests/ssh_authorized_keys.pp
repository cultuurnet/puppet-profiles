class profiles::ssh_authorized_keys(
  Hash $keys = {}
) inherits ::profiles {

  $keys.each | $key, $attributes| {
   [$attributes['keys']].flatten.each | $index, $key_attributes | {
      if size([$attributes['keys']].flatten) == 1 {
        $key_title = $key
      } else {
        $key_number = $index + 1
        $key_title  = "${key} ${key_number}"
      }

      @ssh_authorized_key { $key_title:
        user => 'ubuntu',
        type => $key_attributes['type'],
        key  => $key_attributes['key'],
        tag  => $attributes['tag']
      }
    }
  }
}
