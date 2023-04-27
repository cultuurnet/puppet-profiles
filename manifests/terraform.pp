class profiles::terraform (
  String $version = 'latest'
) inherits ::profiles {

  realize Apt::Source['publiq-tools']

  package { "terraform":
    ensure => $version
  }

  package { "terrafile":
    ensure => latest
  }
}
