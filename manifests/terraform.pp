class profiles::terraform (
  String $version           = 'latest'
  String $terrafile_version = 'latest'
) inherits ::profiles {

  realize Apt::Source['publiq-tools']

  package { "terraform":
    ensure => $version
  }

  package { "terrafile":
    ensure => $terrafile_version
  }
}
