class profiles::resqueweb {

  contain ::profiles

  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']

  contain ::resqueweb

  Profiles::Apt::Update['cultuurnet-tools'] -> Class['resqueweb']
}
