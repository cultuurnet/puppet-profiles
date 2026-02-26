class profiles::jenkins::buildtools::homebuilt inherits ::profiles {

  realize Apt::Source['publiq-tools']

  realize Package['golang']
  realize Package['kubectl']
  realize Package['argocd']
  realize Package['maven']
}
