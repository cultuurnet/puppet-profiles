class profiles::php {

  contain ::profiles

  realize Package['composer']
}
