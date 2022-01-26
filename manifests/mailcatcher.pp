class profiles::mailcatcher inherits ::profiles {

  realize Apt::Source['cultuurnet-tools']

  class { '::mailcatcher':
    manage_repo => false
  }

  Apt::Source['cultuurnet-tools'] -> Class['mailcatcher']
}
