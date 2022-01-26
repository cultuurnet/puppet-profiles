class profiles::nodejs (
  String $version = '10.14.0-1nodesource1'
) inherits ::profiles {

  include ::profiles::packages

  $major_version = split($version, /\./)[0]

  realize Apt::Source["nodejs_${major_version}.x"]
  realize Apt::Source['yarn']

  realize Package['yarn']

  class { '::nodejs':
    manage_package_repo   => false,
    nodejs_package_ensure => $version
  }

  Apt::Source["nodejs_${major_version}.x"] -> Class['nodejs']
  Class['nodejs'] -> Package['yarn']
}
