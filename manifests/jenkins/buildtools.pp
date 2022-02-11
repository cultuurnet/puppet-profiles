class profiles::jenkins::buildtools inherits ::profiles {

  realize Apt::Source['cultuurnet-tools']

  realize Package['git']
  realize Package['jq']
  realize Package['jtm']

  class { '::profiles::ruby':
    with_dev => true
  }
}
