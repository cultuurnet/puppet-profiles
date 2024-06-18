class profiles::jenkins::buildtools inherits ::profiles {

  realize Apt::Source['publiq-tools']

  realize Package['git']
  realize Package['jq']
  realize Package['build-essential']
  realize Package['kubectl']

  include profiles::ruby
}
