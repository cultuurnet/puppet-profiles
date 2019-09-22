class profiles::php {

  contain ::profiles

  include ::profiles::packages
  include ::profiles::repositories

  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['cultuurnet-tools']

  realize Apt::Source['php']
  realize Profiles::Apt::Update['php']

  contain ::php::globals
  contain ::php

  Profiles::Apt::Update['php'] -> Class['php::globals'] -> Class['php']

  realize Package['composer']
  realize Package['git']
}
