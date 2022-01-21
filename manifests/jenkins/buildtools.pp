class profiles::jenkins::buildtools inherits ::profiles {

  include ::profiles::packages
  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']

  realize Package['git']
  realize Package['jq']

  class { '::profiles::ruby':
    with_dev => true
  }
}
