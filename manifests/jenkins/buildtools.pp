class profiles::jenkins::buildtools inherits ::profiles {

  include ::profiles::packages
  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']
  realize Profiles::Apt::Update['yarn']

  realize Package['git']
  realize Package['jq']
  realize Package['yarn']

  class { '::profiles::ruby':
    with_dev => true
  }
}
