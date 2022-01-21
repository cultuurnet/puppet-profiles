class profiles::php (
  Integer[1, 2] $with_composer_default_version = 1
) inherits ::profiles {

  include ::profiles::packages
  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']
  realize Profiles::Apt::Update['php']

  contain ::php::globals
  contain ::php

  realize Package['composer']
  realize Package['composer1']
  realize Package['composer2']
  realize Package['git']

  Package['composer'] -> Package['composer1']
  Package['composer'] -> Package['composer2']
  Class['php'] -> Package['composer1']
  Class['php'] -> Package['composer2']

  alternatives { 'composer':
    path    => "/usr/bin/composer${with_composer_default_version}",
    require => [ Package['composer1'], Package['composer2']]
  }

  Profiles::Apt::Update['php'] -> Class['php::globals'] -> Class['php']
}
