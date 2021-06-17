define profiles::apache::vhost::redirect (
  Stdlib::Httpurl                $destination,
  Boolean                        $https        = false,
  Variant[String, Array[String]] $aliases      = []
) {

  include ::profiles
  include ::profiles::firewall
  include ::profiles::apache

  # TODO: solution for certificate when using an HTTPS vhost

  if $https {
    $port = 443
    realize Firewall['300 accept HTTPS traffic']
  } else {
    $port = 80
    realize Firewall['300 accept HTTP traffic']
  }

  ::apache::vhost { "${title}:${port}":
    servername      => $title,
    serveraliases   => $aliases,
    port            => $port,
    ssl             => $https,
    docroot         => '/var/www/html',
    manage_docroot  => false,
    request_headers => [ 'unset Proxy early'],
    redirect_dest   => $destination,
    redirect_status => 'permanent'
  }
}
