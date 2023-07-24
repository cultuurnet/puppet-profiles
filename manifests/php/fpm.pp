class profiles::php::fpm (
  String                            $php_version          = '8.1',
  String                            $apache_proxy_handler = undef,
  Hash                              $vhosts               = {}
) inherits ::profiles {

  $vhosts.each |$url,$properties| {
    profiles::apache::vhost::php_fpm { "${url}":
      *                     => $properties,
      apache_proxy_handler  => $apache_proxy_handler,
    }
  }
}
