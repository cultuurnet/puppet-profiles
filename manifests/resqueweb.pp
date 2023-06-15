class profiles::resqueweb inherits ::profiles {

  realize Apt::Source['publiq-tools']

  contain ::resqueweb

  Apt::Source['publiq-tools'] -> Class['resqueweb']
}
