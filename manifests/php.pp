class profiles::php {

  contain ::profiles

  realize Apt::Source['php']

  realize Package['composer']
  realize Package['git']
}
