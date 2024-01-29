define profiles::apache::vhost::php_fpm (
  String                         $basedir,
  String                         $public_web_directory = 'public',
  Variant[String, Array[String]] $aliases              = [],
  Enum['unix', 'tcp']            $socket_type          = lookup('profiles::php::fpm_socket_type', Enum['unix', 'tcp'], 'first', 'unix'),
  Optional[String]               $certificate          = undef,
  Optional[Array]                $rewrites             = undef
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
    servername         => $servername,
    serveraliases      => [$aliases].flatten,
    port               => $port,
    ssl                => $https,
    ssl_cert           => $ssl_cert,
    ssl_key            => $ssl_key,
    docroot            => "${basedir}/${public_web_directory}",
    manage_docroot     => false,
    access_log_format  => 'extended_json',
    access_log_env_var => '!nolog',
    setenvif           => [
                            'X-Forwarded-Proto "https" HTTPS=on',
                            'X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+).*" CLIENT_IP=$1'
                          ],
    request_headers    => [
                            'unset Proxy early',
                            "setifempty X-Forwarded-Port \"${port}\"",
                            "setifempty X-Forwarded-Proto \"${transport}\""
                          ],
    directories        => [
                            {
                              'path'            => '\.php$',
                              'provider'        => 'filesmatch',
                              'custom_fragment' => $socket_type ? {
                                                     'unix' => 'SetHandler "proxy:unix:/var/run/php/php-fpm.sock|fcgi://localhost"',
                                                     'tcp'  => 'SetHandler "proxy:fcgi://127.0.0.1:9000"'
                                                   }
                            },
                            {
                              'path'           => $basedir,
                              'options'        => ['Indexes','FollowSymLinks','MultiViews'],
                              'allow_override' => 'All'
                            }
                          ],
    rewrites           => $rewrites
  }
}
