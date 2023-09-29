class profiles::nodejs (
  Optional[String] $version       = undef,
  Integer          $major_version = if $version { Integer(split($version, /\./)[0]) } else { 16 }
) inherits ::profiles {

  if ($version and $major_version) {
    if Integer(split($version, /\./)[0]) != $major_version {
      fail("Profiles::Nodejs: incompatible combination of 'version' and 'major_version' parameters")
    }
  }

  realize Apt::Source["publiq-nodejs-${major_version}"]
  realize Apt::Source["nodejs-${major_version}"]
  realize Apt::Source['publiq-tools']

  realize Package['yarn']

  class { '::nodejs':
    manage_package_repo   => false,
    nodejs_package_ensure => $version
  }

  Apt::Source["nodejs-${major_version}"] -> Class['nodejs']
  Class['nodejs'] -> Package['yarn']
}
