class profiles::apache::mod::php inherits ::profiles {

  case $::operatingsystemrelease {
    '14.04', '16.04': {
      realize Apt::Source['php']

      Apt::Source['php'] -> Class['apache::mod::php']
    }
  }

  contain ::apache::mod::php
}
