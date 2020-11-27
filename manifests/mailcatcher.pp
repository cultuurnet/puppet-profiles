class profiles::mailcatcher {

  contain ::profiles

  include ::profiles::apt::repositories

  realize Profiles::Apt::Update['cultuurnet-tools']

  class { '::mailcatcher':
    manage_repo => false
  }

  Profiles::Apt::Update['cultuurnet-tools'] -> Class['mailcatcher']
}
