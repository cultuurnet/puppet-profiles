class profiles::ssh_authorized_keys(
  Hash $keys = {}
) inherits ::profiles {

  $keys.each | $key, $attributes| {
   [$attributes['key']].flatten.each | $index, $attribute_key | {
      if size([$attributes['key']].flatten) == 1 {
        $key_title = $key
      } else {
        $key_number = $index + 1
        $key_title  = "${key} ${key_number}"
      }

      @ssh_authorized_key { $key_title:
        user => 'ubuntu',
        type => $attributes['type'],
        key  => $attribute_key,
        tag  => $attributes['tag']
      }
    }
  }
}
