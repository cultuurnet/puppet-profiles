class profiles::sysctl (
  Hash $settings = {}
) {

  contain ::profiles

  $settings.each | $setting, $attributes| {
    sysctl { $setting:
      * => $attributes
    }
  }
}
