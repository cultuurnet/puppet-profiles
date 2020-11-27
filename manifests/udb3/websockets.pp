class profiles::udb3::websockets (
  String $config_source
) {
  contain ::profiles

  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']

  class { '::websockets::udb3':
    config_source => $config_source,
    require       => Profiles::Apt::Update['cultuurnet-tools']
  }
}
