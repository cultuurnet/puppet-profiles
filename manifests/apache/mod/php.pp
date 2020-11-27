class profiles::apache::mod::php {

  contain ::profiles

  include ::profiles::apt::repositories

  realize Profiles::Apt::Update['php']

  contain ::apache::mod::php

  Profiles::Apt::Update['php'] -> Class['apache::mod::php']
}
