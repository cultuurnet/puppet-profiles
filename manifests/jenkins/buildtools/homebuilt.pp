class profiles::jenkins::buildtools::homebuilt inherits ::profiles {

  realize Apt::Source['publiq-tools']

  realize Package['argocd']
  realize Package['awscli']
  realize Package['golang']
  realize Package['kubectl']
  realize Package['maven']
}
