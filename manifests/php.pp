class profiles::php (
  Integer[1, 2]    $with_composer_default_version = 1,
  Boolean          $newrelic_agent_enabled        = false,
  String           $newrelic_app_name             = ${facts['networking']['hostname']}.machines.publiq.be},
  Optional[String] $newrelic_license_key          = undef
) inherits ::profiles {

  realize Apt::Source['cultuurnet-tools']
  realize Apt::Source['php']

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

  if $newrelic_agent_enabled {
    realize Apt::Source['newrelic']

    file { 'newrelic-php5-installer.preseed':
      path    => '/var/tmp/newrelic-php5-installer.preseed',
      content => template('profiles/php/newrelic-php5-installer.preseed.erb'),
      mode    => '0600',
      backup  => false
    }

    package { 'newrelic-php5':
      ensure       => 'latest',
      responsefile => '/var/tmp/newrelic-php5-installer.preseed',
      require      => [File['newrelic-php5-installer.preseed']]
    }
  }

  Apt::Source['php'] -> Class['php::globals'] -> Class['php']
}
