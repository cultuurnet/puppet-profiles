class profiles {
  case $::operatingsystem {
    'Ubuntu': {
      case $::operatingsystemrelease {
        '14.04','16.04','18.04': {
          contain ::profiles::groups
          contain ::profiles::users
          contain ::profiles::packages
          contain ::profiles::stages
          contain ::profiles::apt

          class { 'profiles::apt::repositories': stage => 'pre' }

          # TODO: Integrate in class above when incorporating deployment module
          class { 'deployment::repositories': stage => 'pre' }
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
