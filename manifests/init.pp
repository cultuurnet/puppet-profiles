class profiles {
  case $::operatingsystem {
    'Ubuntu': {
      case $::operatingsystemrelease {
        '20.04': {
          contain ::profiles::groups
          contain ::profiles::users
          contain ::profiles::packages
          contain ::profiles::stages
          contain ::profiles::apt

          class { 'profiles::apt::repositories': stage => 'pre' }
        }
        default: {
          fail("Ubuntu ${::operatingsystemrelease} not supported")
        }
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
