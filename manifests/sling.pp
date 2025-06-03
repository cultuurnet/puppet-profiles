class profiles::sling (
  String $version           = 'latest',
) inherits ::profiles {

  realize Apt::Source['publiq-tools']

  package { 'sling':
    ensure  => $version,
    require => Apt::Source['publiq-tools']
  }
}
