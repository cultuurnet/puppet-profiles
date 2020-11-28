class profiles::mailcatcher {

  contain ::profiles

  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']

  class { '::mailcatcher':
    manage_repo => false
  }

  Profiles::Apt::Update['cultuurnet-tools'] -> Class['mailcatcher']
}
