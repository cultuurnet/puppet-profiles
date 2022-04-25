class profiles::icinga2 inherits ::profiles {

  if versioncmp( $facts['os']['release']['major'], '16.04') >= 0 {
    realize Apt::Source['cultuurnet-tools']

    package { 'icinga2-plugins-systemd-service':
      ensure  => 'present',
      require => Apt::Source['cultuurnet-tools']
    }
  }
}
