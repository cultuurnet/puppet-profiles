class profiles::php (
  Integer[1, 2]    $with_composer_default_version        = 1,
  Boolean          $newrelic_agent_enabled               = false,
  String           $newrelic_app_name                    = "${facts['networking']['hostname']}.machines.publiq.be",
  Optional[String] $newrelic_license_key                 = undef,
  Boolean          $newrelic_distributed_tracing_enabled = false
) inherits ::profiles {

  realize Apt::Source['cultuurnet-tools']

  case $::operatingsystemrelease {
    '14.04', '16.04': {
      realize Apt::Source['php']

      Apt::Source['php'] -> Class['php::globals']
    }
  }

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

    if $newrelic_distributed_tracing_enabled == false {
      $php_version = lookup('php::globals::php_version', Optional[String], 'first', '7.4')

      augeas { "newrelic.ini":
        notify  => Service[httpd],
        require => Package[newrelic-php5],
        context => "/files/etc/php/${php_version}/apache2/conf.d/20-newrelic.ini/newrelic",
        changes => [
          "set newrelic.distributed_tracing_enabled false",
        ];
      }
    }
  }

  Class['php::globals'] -> Class['php']
}
