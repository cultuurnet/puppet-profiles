class profiles::apache::mod::php {

  contain ::profiles

  include ::profiles::repositories

  realize Apt::Source['php']
  realize Profiles::Apt::Update['php']

  contain ::apache::mod::php

  Profiles::Apt::Update['php'] -> Class['apache::mod::php']
}
