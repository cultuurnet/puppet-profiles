class profiles::nodejs (
  String $version = '14.16.1-1nodesource1'
) inherits ::profiles {

  $major_version = split($version, /\./)[0]

  realize Apt::Source["publiq-nodejs-${major_version}"]
  realize Apt::Source['yarn']

  realize Package['yarn']

  class { '::nodejs':
    manage_package_repo   => false,
    nodejs_package_ensure => $version
  }

  Apt::Source["publiq-nodejs-${major_version}"] -> Class['nodejs']
  Class['nodejs'] -> Package['yarn']
}
