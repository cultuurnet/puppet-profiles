class profiles::ssh_authorized_keys(
  Hash $keys = {}
) {

  $keys.each | $key, $attributes| {
    any2array($attributes['key']).each | $index, $attribute_key | {
      if size(any2array($attributes['key'])) == 1 {
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
