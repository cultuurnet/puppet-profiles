class profiles::jenkins::buildtools inherits ::profiles {

  realize Apt::Source['publiq-tools']

  realize Package['git']
  realize Package['jq']
  realize Package['build-essential']
  realize Package['kubectl']
  realize Package['argocd']
  realize Package['mysql-client']

  include profiles::ruby
}
