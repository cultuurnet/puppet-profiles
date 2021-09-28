class profiles::apache::mod::php inherits ::profiles {

  include ::profiles::apt::updates

  realize Profiles::Apt::Update['php']

  contain ::apache::mod::php

  Profiles::Apt::Update['php'] -> Class['apache::mod::php']
}
