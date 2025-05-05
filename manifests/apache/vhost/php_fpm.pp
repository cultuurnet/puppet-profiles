define profiles::apache::vhost::php_fpm (
  String                         $basedir,
  String                         $public_web_directory     = 'public',
  Optional[Hash]                 $newrelic_optional_config = {},
  Variant[String, Array[String]] $aliases                  = [],
  Enum['on', 'off', 'nodecode']  $allow_encoded_slashes    = 'off',
  String                         $access_log_format        = 'extended_json',
  Enum['unix', 'tcp']            $socket_type              = lookup('profiles::php::fpm_socket_type', Enum['unix', 'tcp'], 'first', 'unix'),
  Optional[String]               $certificate              = undef,
  Variant[String, Array[String]] $headers                  = [],
  Variant[Hash, Array[Hash]]     $directories              = [],
  Variant[Hash, Array[Hash]]     $rewrites                 = [],
  Boolean                        $ssl_proxyengine          = false
) {

  include ::profiles
  include ::profiles::apache
  include ::profiles::firewall::rules
  include ::apache::mod::proxy
  include ::apache::mod::proxy_fcgi
  include ::apache::mod::rewrite

  unless $title =~ Stdlib::Httpurl {
    fail("Defined resource type Profiles::Apache::Vhost::Php_Fpm[${title}] expects the title to be a valid HTTP(S) URL")
  }

  $transport        = split($title, ':')[0]
  $servername       = split($title, '/')[-1]
  $newrelic_enabled = lookup('profiles::php::newrelic', Boolean, 'first', false)

  if $transport == 'https' {
    unless $certificate {
      fail("Defined resource type Profiles::Apache::Vhost::Php_Fpm[${title}] expects a value for parameter certificate when using HTTPS")
    }

    $https        = true
    $port         = 443
    $ssl_cert     = "/etc/ssl/certs/${certificate}.bundle.crt"
    $ssl_key      = "/etc/ssl/private/${certificate}.key"

    include ::profiles::certificates

    realize Profiles::Certificate[$certificate]
    realize Firewall['300 accept HTTPS traffic']

    Profiles::Certificate[$certificate] -> Apache::Vhost["${servername}_${port}"]
    Profiles::Certificate[$certificate] ~> Class['apache::service']
  } else {
    $https        = false
    $port         = 80
    $ssl_cert     = undef
    $ssl_key      = undef

    realize Firewall['300 accept HTTP traffic']
  }

  apache::vhost { "${servername}_${port}":
    servername            => $servername,
    serveraliases         => [$aliases].flatten,
    port                  => $port,
    ssl                   => $https,
    ssl_cert              => $ssl_cert,
    ssl_key               => $ssl_key,
    docroot               => "${basedir}/${public_web_directory}",
    manage_docroot        => false,
    access_log_format     => $access_log_format,
    access_log_env_var    => '!nolog',
    allow_encoded_slashes => $allow_encoded_slashes,
    setenvif              => $profiles::apache::defaults::setenvif,
    request_headers       => $profiles::apache::defaults::request_headers + [
                               "setifempty X-Forwarded-Port \"${port}\"",
                               "setifempty X-Forwarded-Proto \"${transport}\""
                             ],
    headers               => [$headers].flatten,
    directories           => [
                               {
                                 'path'            => '\.php$',
                                 'provider'        => 'filesmatch',
                                 'custom_fragment' => $socket_type ? {
                                                        'unix' => 'SetHandler "proxy:unix:/run/php/php-fpm.sock|fcgi://localhost"',
                                                        'tcp'  => 'SetHandler "proxy:fcgi://127.0.0.1:9000"'
                                                      }
                               },
                               { 'path' => $basedir } + $profiles::apache::defaults::directories
                             ] + [$directories].flatten,
    rewrites              => [$rewrites].flatten,
    ssl_proxyengine       => $ssl_proxyengine
  }

  profiles::newrelic::php::application { $servername:
    enable          => $newrelic_enabled,
    docroot         => "${basedir}/${public_web_directory}",
    optional_config => $newrelic_optional_config
  }
}
