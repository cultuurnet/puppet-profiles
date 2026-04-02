class profiles::jenkins::buildtools::extra inherits ::profiles {

  realize Apt::Source['publiq-tools']

  realize Package['mysql-client']

  realize Package['argocd']
  realize Package['awscli']
  realize Package['golang']
  realize Package['kubectl']
  realize Package['maven']
}
