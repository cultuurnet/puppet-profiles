define profiles::apache::vhost::reverse_proxy (
  Stdlib::Httpurl                $destination,
  Optional[String]               $certificate           = undef,
  Enum['on', 'off', 'nodecode']  $allow_encoded_slashes = 'off',
  Boolean                        $preserve_host         = false,
  Variant[String, Array[String]] $proxy_keywords        = [],
  Variant[String, Array[String]] $aliases               = []
) {

  include ::profiles
  include ::profiles::firewall
  include ::profiles::apache
  include ::profiles::certificates

  unless $title =~ Stdlib::Httpurl {
    fail("Defined resource type Profiles::Apache::Vhost::Reverse_proxy[${title}] expects the title to be a valid HTTP URL")
  }

  $transport = split($title, ':')[0]
  $servername = split($title, '/')[-1]

  if $transport == 'https' {
    unless $certificate {
      fail("Defined resource type Profiles::Apache::Vhost::Reverse_proxy[${title}] expects a value for parameter certificate when using HTTPS")
    }

    $https        = true
    $port         = 443
    $ssl_cert     = "/etc/ssl/certs/${certificate}.bundle.crt"
    $ssl_key      = "/etc/ssl/private/${certificate}.key"
    $reverse_urls = [$destination, "http://${servername}/"]

    realize Profiles::Certificate[$certificate]
    realize Firewall['300 accept HTTPS traffic']

    Profiles::Certificate[$certificate] -> Apache::Vhost["${servername}_${port}"]
    Profiles::Certificate[$certificate] ~> Class['apache::service']
  } else {
    $https        = false
    $port         = 80
    $ssl_cert     = undef
    $ssl_key      = undef
    $reverse_urls = $destination

    realize Firewall['300 accept HTTP traffic']
  }

  if $destination =~ /^https/ {
    $https_destination = true
  } else {
    $https_destination = false
  }

  apache::vhost { "${servername}_${port}":
    servername            => $servername,
    serveraliases         => $aliases,
    port                  => $port,
    ssl                   => $https,
    ssl_cert              => $ssl_cert,
    ssl_key               => $ssl_key,
    docroot               => '/var/www/html',
    manage_docroot        => false,
    request_headers       => [
                               'unset Proxy early',
                               "set X-Forwarded-Port \"${port}\"",
                               "set X-Forwarded-Proto \"${transport}\""
                             ],
    ssl_proxyengine       => $https_destination,
    allow_encoded_slashes => $allow_encoded_slashes,
    proxy_preserve_host   => $preserve_host,
    proxy_pass            => {
                               'path'         => '/',
                               'url'          => $destination,
                               'keywords'     => $proxy_keywords,
                               'reverse_urls' => $reverse_urls
                             }
  }
}
