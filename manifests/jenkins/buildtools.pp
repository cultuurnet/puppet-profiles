class profiles::jenkins::buildtools inherits ::profiles {

  include ::profiles::packages

  realize Apt::Source['cultuurnet-tools']

  realize Package['git']
  realize Package['jq']
  realize Package['jtm']

  class { '::profiles::ruby':
    with_dev => true
  }
}
