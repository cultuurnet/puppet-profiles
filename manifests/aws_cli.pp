class profiles::aws_cli (
  String $version           = 'latest',
) inherits ::profiles {

  realize Apt::Source['publiq-tools']

  package { 'aws-cli':
    ensure  => $version,
    require => Apt::Source['publiq-tools']
  }
}
