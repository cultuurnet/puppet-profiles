class profiles {
  case $::operatingsystem {
    'Ubuntu': {
      case $::operatingsystemrelease {
        '14.04','16.04': {
          contain ::profiles::stages
          contain ::profiles::apt

          class { 'profiles::apt::repositories':
            stage => 'pre'
          }

          class { 'profiles::jenkins::repositories':
            stage => 'pre'
          }

          class { 'profiles::deployment::repositories':
            stage => 'pre'
          }
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
