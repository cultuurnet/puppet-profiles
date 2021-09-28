class profiles::sysctl (
  Hash $settings = {}
) inherits ::profiles {

  $settings.each | $setting, $attributes| {
    sysctl { $setting:
      * => $attributes
    }
  }
}
