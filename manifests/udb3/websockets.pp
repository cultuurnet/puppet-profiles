class profiles::udb3::websockets (
  String $config_source,
  String $version       = 'latest'
) inherits ::profiles {

  realize Apt::Source['cultuurnet-tools']

  class { '::websockets::udb3':
    package_version => $version,
    config_source   => $config_source,
    require         => Apt::Source['cultuurnet-tools']
  }
}