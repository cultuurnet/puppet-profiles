class profiles::ssh_authorized_keys(
  Hash $keys = {}
) {

  $keys.each | $key, $attributes| {
    @ssh_authorized_key { $key:
      user => 'ubuntu',
      type => $attributes['type'],
      key  => $attributes['key'],
      tag  => $attributes['tag']
    }
  }
}
