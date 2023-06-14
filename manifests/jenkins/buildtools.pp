class profiles::jenkins::buildtools inherits ::profiles {

  realize Apt::Source['cultuurnet-tools']

  realize Package['git']
  realize Package['jq']
  realize Package['build-essential']

  include profiles::ruby
}
