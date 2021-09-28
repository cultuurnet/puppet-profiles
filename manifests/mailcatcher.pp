class profiles::mailcatcher inherits ::profiles {

  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']

  class { '::mailcatcher':
    manage_repo => false
  }

  Profiles::Apt::Update['cultuurnet-tools'] -> Class['mailcatcher']
}
