class profiles::nodejs (
  String $version = '10.14.0-1nodesource1'
) inherits ::profiles {

  $major_version = split($version, /\./)[0]

  case $::operatingsystemrelease {
    '14.04', '16.04': {
      # original apt.uitdatabank.be repo
      $apt_repo = "nodejs_${major_version}.x"
    }
    '18.04': {
      # new apt.publiq.be repo
      $apt_repo = "nodejs_${major_version}"
    }
    default: {
      fail("ERROR: No nodejs apt repository available for OS ${::operatingsystem}")
    }
  }

  realize Apt::Source[$apt_repo]
  realize Apt::Source['yarn']

  realize Package['yarn']

  class { '::nodejs':
    manage_package_repo   => false,
    nodejs_package_ensure => $version
  }

  Apt::Source[$apt_repo] -> Class['nodejs']
  Class['nodejs'] -> Package['yarn']
}
