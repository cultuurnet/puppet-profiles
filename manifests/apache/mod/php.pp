class profiles::apache::mod::php inherits ::profiles {

  realize Apt::Source['php']

  contain ::apache::mod::php

  Apt::Source['php'] -> Class['apache::mod::php']
}
