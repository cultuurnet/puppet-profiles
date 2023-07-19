# Defined type profiles::apache::vhost::php_fpm
#
# This will deploy an apache vhost with php fpm enabled
# Example hiera config:
#
# ---
# classes:
#   - profiles::php_fpm
# 
# profiles::php_fpm::vhosts:
#   'http://phpfpmtest.publiq.be':
#      aliases: 'fpmalias.publiq.be'
#      docroot: '/var/www/phpfpmtest'
#      php_version: '8.1'
#      fpm_listen: 'tcp_socket'

define profiles::apache::vhost::php_fpm (
  String                            $docroot               = undef,
  String                            $php_version           = '8.1',
  Optional[String]                  $certificate           = undef,
  Enum['unix_socket', 'tcp_socket'] $fpm_listen            = 'unix_socket',
  Enum['on', 'off', 'nodecode']     $allow_encoded_slashes = 'off',
  Variant[String, Array[String]]    $aliases               = [],
  Boolean                           $newrelic_agent        = false,
  Optional[String]                  $newrelic_license_key  = undef
) {

  include ::profiles
  include ::profiles::apache
  include ::profiles::certificates
  include ::apache::mod::proxy
  include ::apache::mod::proxy_fcgi

  realize Group['www-data']
  realize User['www-data']

  unless $title =~ Stdlib::Httpurl {
    fail("Defined resource type Profiles::Apache::Vhost::Php_Fpm[${title}] expects the title to be a valid HTTP(S) URL")
  }

  $transport  = split($title, ':')[0]
  $servername = split($title, '/')[-1]

  if $transport == 'https' {
    unless $certificate {
      fail("Defined resource type Profiles::Apache::Vhost::Php_Fpm[${title}] expects a value for parameter certificate when using HTTPS")
    }

    $https        = true
    $port         = 443
    $ssl_cert     = "/etc/ssl/certs/${certificate}.bundle.crt"
    $ssl_key      = "/etc/ssl/private/${certificate}.key"

    realize Profiles::Certificate[$certificate]

    Profiles::Certificate[$certificate] -> Apache::Vhost["${servername}_${port}"]
    Profiles::Certificate[$certificate] ~> Class['apache::service']
  } else {
    $https        = false
    $port         = 80
    $ssl_cert     = undef
    $ssl_key      = undef
  }

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

  file { $docroot:
    ensure => 'directory',
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
    require => [User['www-data'],Group['www-data']]
  }

  apache::vhost { "${servername}_${port}":
    servername            => $servername,
    serveraliases         => $aliases,
    port                  => $port,
    ssl                   => $https,
    ssl_cert              => $ssl_cert,
    ssl_key               => $ssl_key,
    docroot               => $docroot,
    manage_docroot        => false,
    request_headers       => [
                               "setifempty X-Forwarded-Port \"${port}\"",
                               "setifempty X-Forwarded-Proto \"${transport}\""
                             ],
    allow_encoded_slashes => $allow_encoded_slashes,
    directories           => [{
                               'path'            => '\.php$',
                               'provider'        => 'filesmatch',
                               'custom_fragment' => $apache_proxy_handler,
                             }]
  }
}
