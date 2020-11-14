class profiles::mailcatcher {

  contain ::profiles

  include ::profiles::apt::repositories

  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['cultuurnet-tools']

  class { '::mailcatcher':
    manage_repo => false
  }

  Profiles::Apt::Update['cultuurnet-tools'] -> Class['mailcatcher']
}
