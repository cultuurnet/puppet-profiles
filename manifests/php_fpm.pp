class profiles::php_fpm (
  Hash $vhosts = {}
) inherits ::profiles {

  $vhosts.each |$url,$properties| {
    profiles::apache::vhost::php_fpm { "${url}":
      * => $properties
    }
  }
}
