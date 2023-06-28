class profiles::php (
  String                  $version                  = '7.4',
  Hash                    $extensions               = {},
  Hash                    $settings                 = {},
  Optional[Integer[1, 2]] $composer_default_version = undef,
  Boolean                 $fpm                      = false,
  Boolean                 $newrelic_agent           = false,
  String                  $newrelic_app_name        = $facts['networking']['fqdn'],
  Optional[String]        $newrelic_license_key     = undef
) inherits ::profiles {

  $default_extensions = {
                          'bcmath'   => {},
                          'curl'     => {},
                          'gd'       => {},
                          'intl'     => {},
                          'mbstring' => {},
                          'opcache'  => { 'zend' => true },
                          'readline' => {},
                          'tidy'     => {},
                          'xml'      => {},
                          'zip'      => {}
                        }

  $version_dependent_default_extensions = $version ? {
    '7.4'   => { 'json' => {} },
    default => {}
  }

  realize Apt::Source['php']

  realize Package['composer']

  class { ::php::globals:
    php_version => $version,
    config_root => "/etc/php/${version}"
  }

  class { ::php:
    manage_repos => false,
    composer     => false,
    dev          => false,
    pear         => false,
    fpm          => $fpm,
    settings     => $settings,
    extensions   => $default_extensions + $version_dependent_default_extensions + $extensions
  }

  Apt::Source['php'] -> Class['php::globals']
  Class['php::globals'] -> Class['php']

  if $composer_default_version {
    realize Apt::Source['publiq-tools']

    realize Package['composer1']
    realize Package['composer2']
    realize Package['git']

    Package['composer'] -> Package['composer1']
    Package['composer'] -> Package['composer2']
    Class['php'] -> Package['composer1']
    Class['php'] -> Package['composer2']

    alternatives { 'composer':
      path    => "/usr/bin/composer${composer_default_version}",
      require => [ Package['composer1'], Package['composer2']]
    }
  }

  if $newrelic_agent {
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

  Class['php::globals'] -> Class['php']
}
