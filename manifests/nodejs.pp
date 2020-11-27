class profiles::nodejs (
  String $version = '10.14.0-1nodesource1'
) {

  contain ::profiles

  include ::profiles::apt::updates

  $major_version = split($version, /\./)[0]

  realize Profiles::Apt::Update["nodejs_${major_version}.x"]

  class { '::nodejs':
    manage_package_repo   => false,
    nodejs_package_ensure => $version
  }

  Profiles::Apt::Update["nodejs_${major_version}.x"] -> Class['nodejs']
}
