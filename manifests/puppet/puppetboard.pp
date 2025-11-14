class profiles::puppet::puppetboard (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases   = [],
  Stdlib::IP::Address::V4        $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged     $service_port    = 6000,
  Enum['running', 'stopped']     $service_status  = 'running',
  Boolean                        $auth            = false
) inherits ::profiles {

  $basedir = '/var/www/puppetboard'

  include profiles::apache

  realize Apt::Source['publiq-tools']
  realize Group['www-data']
  realize User['www-data']

  class { 'profiles::puppet::puppetboard::certificate':
    certname => $servername,
    basedir  => $basedir,
    notify   => Service['puppetboard'],
  }

  class { '::puppetboard':
    install_from        => 'package',
    package_name        => 'puppetboard',
    group               => 'www-data',
    user                => 'www-data',
    manage_group        => false,
    manage_user         => false,
    secret_key          => fqdn_rand_string(32, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'),
    puppetdb_host       => '127.0.0.1',
    puppetdb_port       => 8081,
    puppetdb_ssl_verify => "${basedir}/ssl/ca.pem",
    puppetdb_key        => "${basedir}/ssl/private.pem",
    puppetdb_cert       => "${basedir}/ssl/public.pem",
    enable_catalog      => false,
    enable_query        => true,
    default_environment => 'production',
    reports_count       => 20,
    settings_file       => "${basedir}/settings.py",
    extra_settings      => {},
    require             => [Apt::Source['publiq-tools'], Group['www-data'], User['www-data'], Class['profiles::puppet::puppetboard::certificate']],
    notify              => Service['puppetboard']
  }

  file { 'puppetboard service defaults':
    ensure  => 'file',
    path    => '/etc/default/puppetboard',
    content => "HOST=${service_address}\nPORT=${service_port}",
    notify  => Service['puppetboard']
  }

  service { 'puppetboard':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 }
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination         => "http://${service_address}:${service_port}/",
    aliases             => $serveraliases,
    auth_openid_connect => $auth
  }
}
