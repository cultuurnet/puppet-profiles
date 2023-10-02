class profiles::nodejs (
  String $version = '14.16.1-1nodesource1'
) inherits ::profiles {

  $major_version = split($version, /\./)[0]

  realize Apt::Source['publiq-tools']

  if $major_version in ['16', '18'] {
    realize Apt::Source["nodejs-${major_version}"]
    Apt::Source["nodejs-${major_version}"] -> Class['nodejs']
  } else {
    realize Apt::Source["publiq-nodejs-${major_version}"]
    Apt::Source["publiq-nodejs-${major_version}"] -> Class['nodejs']
  }

  realize Package['yarn']

  class { '::nodejs':
    manage_package_repo   => false,
    nodejs_package_ensure => $version
  }

  Class['nodejs'] -> Package['yarn']
}
