class profiles::mailcatcher {

  contain ::profiles

  include ::profiles::repositories

  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['cultuurnet-tools']

  contain ::mailcatcher

  Profiles::Apt::Update['cultuurnet-tools'] -> Class['mailcatcher']
}
