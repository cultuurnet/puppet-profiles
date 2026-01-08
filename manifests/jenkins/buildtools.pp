class profiles::jenkins::buildtools inherits ::profiles {

  realize Apt::Source['publiq-tools']

  realize Package['git']
  realize Package['jq']
  realize Package['build-essential']
  realize Package['debhelper']
  realize Package['golang']
  realize Package['kubectl']
  realize Package['argocd']
  realize Package['mysql-client']
  realize Package['phantomjs']
  realize Package['maven']

  include profiles::ruby
}
