class profiles::resqueweb inherits ::profiles {

  realize Apt::Source['cultuurnet-tools']

  contain ::resqueweb

  Apt::Source['cultuurnet-tools'] -> Class['resqueweb']
}
