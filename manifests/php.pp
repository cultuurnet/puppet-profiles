class profiles::php {

  contain ::profiles

  include ::profiles::packages
  include ::profiles::repositories

  realize Apt::Source['php']

  realize Package['composer']
  realize Package['git']
}
