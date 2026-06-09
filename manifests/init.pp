class profiles {

  $terraform_integration = lookup('data::puppet::terraform_integration', Boolean, 'first', false)

  if $terraform_integration {
    $terraform_available = lookup('terraform::available', Boolean, 'first', false)

    unless $terraform_available {
      fail('Terraform integration enabled but hieradata not available')
    }
  }

  case $facts['os']['name'] {
    'Ubuntu': {
      case $facts['os']['release']['major'] {
        '20.04', '24.04': {
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
