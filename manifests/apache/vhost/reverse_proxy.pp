define profiles::apache::vhost::reverse_proxy (
  Stdlib::Httpurl                $destination,
  Boolean                        $https        = false,
  Optional[String]               $certificate  = undef,
  Variant[String, Array[String]] $aliases      = []
) {

  include ::profiles
  include ::profiles::firewall
  include ::profiles::apache
  include ::profiles::certificates


  if $https {
    unless $certificate {
      fail("Class ${name} expects a value for parameter certificate when using HTTPS")
    }

    $port     = 443
    $ssl_cert = "/etc/ssl/certs/${certificate}.bundle.crt"
    $ssl_key  = "/etc/ssl/private/${certificate}.key"

    realize Profiles::Certificate[$certificate]
    realize Firewall['300 accept HTTPS traffic']

    Profiles::Certificate[$certificate] -> Apache::Vhost["${title}_${port}"]
    Profiles::Certificate[$certificate] ~> Class['apache::service']
  } else {
    $port = 80
    $ssl_cert = undef
    $ssl_key  = undef

    realize Firewall['300 accept HTTP traffic']
  }

  if $destination =~ /^https/ {
    $https_destination = true
  } else {
    $https_destination = false
  }

  apache::vhost { "${title}_${port}":
    servername      => $title,
    serveraliases   => $aliases,
    port            => $port,
    ssl             => $https,
    ssl_cert        => "/etc/ssl/certs/${certificate}.bundle.crt",
    ssl_key         => "/etc/ssl/private/${certificate}.key",
    docroot         => '/var/www/html',
    manage_docroot  => false,
    request_headers => ['unset Proxy early'],
    ssl_proxyengine => $https_destination,
    proxy_pass      => {
                         'path' => '/',
                         'url'  => $destination
                       }
  }
}
