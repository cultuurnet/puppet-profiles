class profiles::apache {

  contain ::profiles

  class { '::apache':

  }
}
