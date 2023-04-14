class profiles::mailcatcher inherits ::profiles {

  realize Apt::Source['publiq-tools']

  class { '::mailcatcher':
    manage_repo => false
  }

  Apt::Source['publiq-tools'] -> Class['mailcatcher']
}
