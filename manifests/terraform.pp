class profiles::terraform (
  String $version,
  String $terrafile_version
) inherits ::profiles {

  realize Apt::Source['hashicorp']
  realize Apt::Source['publiq-tools']

  package { 'terraform':
    ensure  => $version,
    require => Apt::Source['hashicorp']
  }

  package { 'terrafile':
    ensure  => $terrafile_version,
    require => Apt::Source['publiq-tools']
  }
}
