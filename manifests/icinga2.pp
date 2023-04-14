class profiles::icinga2 inherits ::profiles {

  if versioncmp( $facts['os']['release']['major'], '16.04') >= 0 {
    realize Apt::Source['publiq-tools']

    package { 'icinga2-plugins-systemd-service':
      ensure  => 'present',
      require => Apt::Source['publiq-tools']
    }
  }
}
