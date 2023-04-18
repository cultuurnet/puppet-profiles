class profiles::terraform (
  String $version = '1.4.5-1'
) inherits ::profiles {

  realize Apt::Source['publiq-tools']

  package { "terraform":
    ensure => $version
  }
}
