class profiles::elasticdump {

  contain ::profiles

  include ::profiles::apt::updates
  include ::profiles::nodejs

  realize Profiles::Apt::Update['cultuurnet-tools']

  package { 'elasticdump':
    require => [ Profiles::Apt::Update['cultuurnet-tools'], Class['profiles::nodejs']]
  }
}
