class profiles::sysctl (
  Hash $settings = {}
) {

  contain profiles

  include ::profiles::packages

  realize Package['augeas-tools']
  realize Package['ruby-augeas']

  Sysctl {
    require => [ Package['augeas-tools'], Package['ruby-augeas'] ]
  }

  $settings.each | $setting, $attributes| {
    sysctl { $setting:
      * => $attributes
    }
  }
}
