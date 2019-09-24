class profiles::apache::mod::php {

  contain ::profiles

  include ::profiles::repositories

  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['cultuurnet-tools']

  contain ::apache::mod::php

  Profiles::Apt::Update['cultuurnet-tools'] -> Class['apache::mod::php']
}
