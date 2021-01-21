class profiles::udb3::websockets (
  String $config_source,
  String $version       = 'latest'
) {
  contain ::profiles

  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']

  class { '::websockets::udb3':
    package_version => $version,
    config_source   => $config_source,
    require         => Profiles::Apt::Update['cultuurnet-tools']
  }
}
