# Class profiles::php_fpm
#
# Hiera config example
#
# ---
# classes:
#   - profiles::php_fpm
# 
# profiles::php_fpm::php_version: '8.1'
# profiles::php_fpm::fpm_listen: 'tcp_socket'
# profiles::php_fpm::newrelic_agent: false
# profiles::php_fpm::newrelic_license_key: "%{lookup('newrelic_license_key')}"
# 
# profiles::php_fpm::vhosts:
#   'http://fpmtest1.publiq.be':
#      docroot: '/var/www/fpmtest1'
#      aliases: 'fpmalias.publiq.be'
#   'https://fpmtest2.publiq.be':
#      docroot: '/var/www/fpmtest2'
#      certificate: 'wildcard.publiq.be'

class profiles::php_fpm (
  String                            $php_version          = '8.1',
  Enum['unix_socket', 'tcp_socket'] $fpm_listen           = 'unix_socket',
  Boolean                           $newrelic_agent       = false,
  Optional[String]                  $newrelic_license_key = undef,
  Hash                              $vhosts               = {}
) inherits ::profiles {

  case $fpm_listen {
    'unix_socket': {
      $listen               = "/var/run/php/php${php_version}-fpm.sock"
      $apache_proxy_handler = "SetHandler \"proxy:unix:/var/run/php/php${php_version}-fpm.sock|fcgi://localhost\""
    }
    'tcp_socket': {
      $listen               = "127.0.0.1:9000"
      $apache_proxy_handler = "SetHandler \"proxy:fcgi://127.0.0.1:9000\""
    }
  }

  class { '::profiles::php':
    version                  => $php_version,
    fpm                      => true,
    fpm_service_enable       => true,
    fpm_service_ensure       => 'running',
    fpm_global_pool_settings => {
      listen       => $listen,
      listen_owner => 'www-data',
      listen_group => 'www-data'
    },
    newrelic_agent           => $newrelic_agent,
    newrelic_app_name        => $facts['networking']['fqdn'],
    newrelic_license_key     => $newrelic_license_key
  }

  $vhosts.each |$url,$properties| {
    profiles::apache::vhost::php_fpm { "${url}":
      *                     => $properties,
      apache_proxy_handler  => $apache_proxy_handler,
    }
  }
}
