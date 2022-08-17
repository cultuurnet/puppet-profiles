define profiles::apache::vhost::redirect (
  # Stdlib::Httpurl              $destination,
  String                         $destination,
  Optional[String]               $certificate  = undef,
  Variant[String, Array[String]] $aliases      = []
) {

  include ::profiles
  include ::profiles::firewall::rules
  include ::profiles::apache
  include ::profiles::certificates

  # 2022-08-17 paul: Puppetserver can't find STDLIB module. Implementing temp workaround
  #
  # unless $title =~ Stdlib::Httpurl {
  #   fail("Defined resource type Profiles::Apache::Vhost::Redirect[${title}] expects the title to be a valid HTTP URL")
  # }

  $transport  = split($title, ':')[0]
  $servername = split($title, '/')[-1]
  $dest       = regsubst($destination, /^(.*)\/$/, '\\1')

  if $transport == 'https' {
    unless $certificate {
      fail("Defined resource type Profiles::Apache::Vhost::Redirect[${title}] expects a value for parameter certificate when using HTTPS")
    }

    $https    = true
    $port     = 443
    $ssl_cert = "/etc/ssl/certs/${certificate}.bundle.crt"
    $ssl_key  = "/etc/ssl/private/${certificate}.key"

    realize Profiles::Certificate[$certificate]
    realize Firewall['300 accept HTTPS traffic']

    Profiles::Certificate[$certificate] -> Apache::Vhost["${servername}_${port}"]
    Profiles::Certificate[$certificate] ~> Class['apache::service']
  } else {
    $https    = false
    $port     = 80
    $ssl_cert = undef
    $ssl_key  = undef

    realize Firewall['300 accept HTTP traffic']
  }

  apache::vhost { "${servername}_${port}":
    servername      => $servername,
    serveraliases   => $aliases,
    port            => $port,
    ssl             => $https,
    ssl_cert        => $ssl_cert,
    ssl_key         => $ssl_key,
    docroot         => '/var/www/html',
    manage_docroot  => false,
    request_headers => ['unset Proxy early'],
    redirect_source => '/',
    redirect_dest   => "${dest}/",
    redirect_status => 'permanent'
  }
}
