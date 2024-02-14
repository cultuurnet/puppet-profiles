class profiles {
  case $facts['os']['name'] {
    'Ubuntu': {
      case $facts['os']['release']['major'] {
        '20.04': {
          contain ::profiles::groups
          contain ::profiles::users
          contain ::profiles::packages
          contain ::profiles::stages
          contain ::profiles::apt
          contain ::profiles::files

          class { 'profiles::apt::repositories': stage => 'pre' }
        }
        default: {
          fail("Ubuntu ${facts['os']['release']['major']} not supported")
        }
      }
    }
    default: {
      fail("${facts['os']['name']} not supported")
    }
  }
}
