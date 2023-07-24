define profiles::apache::vhost::php_fpm (
  String                            $docroot               = undef,
  Enum['on', 'off', 'nodecode']     $allow_encoded_slashes = 'off',
  Variant[String, Array[String]]    $aliases               = [],
  String                            $apache_proxy_handler  = undef,
  Optional[String]                  $certificate           = undef
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

  # 2023-07-24 paul: docroot created by apt package
  #
  # file { $docroot:
  #   ensure  => 'directory',
  #   owner   => 'www-data',
  #   group   => 'www-data',
  #   mode    => '0755',
  #   require => [User['www-data'],Group['www-data']]
  # }

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
