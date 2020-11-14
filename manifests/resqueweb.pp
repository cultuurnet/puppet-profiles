class profiles::resqueweb {

  contain ::profiles

  include ::profiles::apt::repositories

  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['cultuurnet-tools']

  contain ::resqueweb

  Profiles::Apt::Update['cultuurnet-tools'] -> Class['resqueweb']
}
