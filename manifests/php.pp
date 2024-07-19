class profiles::php (
  String                     $version                  = '7.4',
  Hash                       $extensions               = {},
  Hash                       $settings                 = {},
  Optional[Integer[1, 2]]    $composer_default_version = undef,
  Boolean                    $fpm                      = true,
  Enum['unix', 'tcp']        $fpm_socket_type          = 'unix',
  Enum['running', 'stopped'] $fpm_service_status       = 'running',
  Boolean                    $newrelic                 = false,
  String                     $newrelic_app_name        = $facts['networking']['fqdn'],
  Optional[String]           $newrelic_license_key     = lookup('data::newrelic::license_key', Optional[String], 'first', undef)
) inherits ::profiles {

  $default_settings   = {
                          'openssl/openssl.cafile' => '/etc/ssl/certs/ca-certificates.crt'
                        }

  $default_extensions = {
                          'apcu'     => {},
                          'bcmath'   => {},
                          'curl'     => {},
                          'gd'       => {},
                          'intl'     => {},
                          'mbstring' => {},
                          'mysql'    => {},
                          'opcache'  => { 'zend' => true },
                          'readline' => {},
                          'redis'    => {},
                          'tidy'     => {},
                          'xml'      => {},
                          'zip'      => {}
                        }

  $version_dependent_default_extensions = $version ? {
    '7.4'   => { 'json' => {} },
    default => {}
  }

  if $fpm {
    $fpm_attributes = {
                        fpm_service_ensure       => $fpm_service_status,
                        fpm_service_enable       => $fpm_service_status ? {
                                                      'running' => true,
                                                      'stopped' => false
                                                    },
                        fpm_pools                => { 'www' => {} }, # https://github.com/voxpupuli/puppet-php/issues/564
                        fpm_global_pool_settings => {
                                                      listen_owner => 'www-data',
                                                      listen_group => 'www-data',
                                                      listen       => $fpm_socket_type ? {
                                                                        'unix' => "/run/php/php${version}-fpm.sock",
                                                                        'tcp'  => '127.0.0.1:9000'
                                                                      }
                                                    }
                      }

    file { 'php-fpm service':
      ensure => 'link',
      path   => '/etc/systemd/system/php-fpm.service',
      target => "/lib/systemd/system/php${version}-fpm.service",
      notify => Systemd::Daemon_reload['php-fpm']
    }

    systemd::daemon_reload { 'php-fpm': }

    file { "/etc/systemd/system/php${version}-fpm.service.d":
      ensure => 'absent',
      force  => true,
      notify => Systemd::Daemon_reload['php-fpm']
    }

  } else {
    $fpm_attributes = {}
  }

  realize Apt::Source['php']
  realize Package['composer']

  class { ::php::globals:
    php_version => $version,
    config_root => "/etc/php/${version}",
    before      => Class['php']
  }

  class { ::php:
    manage_repos => false,
    composer     => false,
    dev          => false,
    pear         => false,
    settings     => $default_settings + $settings,
    extensions   => $default_extensions + $version_dependent_default_extensions + $extensions,
    fpm          => $fpm,
    *            => $fpm_attributes
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
      require => [Package['composer1'], Package['composer2']]
    }
  }

  if $newrelic {
    unless $newrelic_license_key {
      fail("Class Profiles::Php expects a value for parameter 'newrelic_license_key'")
    }

    class { 'profiles::newrelic::php':
      app_name    => $newrelic_app_name,
      license_key => $newrelic_license_key
    }
  }
}
