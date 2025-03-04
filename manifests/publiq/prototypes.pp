class profiles::publiq::prototypes (
  Stdlib::Httpurl  $url,
  Optional[String] $certificate = undef,
  Boolean          $deployment  = true
) inherits ::profiles {

  include ::profiles::apache
  include ::profiles::firewall::rules
  include ::profiles::certificates

  $basedir    = '/var/www/prototypes'
  $transport  = split($url, ':')[0]
  $servername = split($url, '/')[-1]

  if $transport == 'https' {
    unless $certificate {
      fail("Class Profiles::Publiq::Prototypes expects a value for parameter 'certificate' when using HTTPS")
    }

    $https        = true
    $port         = 443
    $ssl_cert     = "/etc/ssl/certs/${certificate}.bundle.crt"
    $ssl_key      = "/etc/ssl/private/${certificate}.key"

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
    docroot           => $basedir,
    servername        => $servername,
    serveraliases     => ["*.${servername}"],
    virtual_docroot   => "${basedir}/%1",
    docroot_owner     => 'www-data',
    docroot_group     => 'www-data',
    request_headers   => $profiles::apache::defaults::request_headers,
    access_log_format => 'extended_json',
    setenvif          => $profiles::apache::defaults::setenvif,
    ssl               => $https,
    port              => $port,
    ssl_cert          => "/etc/ssl/certs/${certificate}.bundle.crt",
    ssl_key           => "/etc/ssl/private/${certificate}.key",
    require           => Class['profiles::apache']
  }

  if $deployment {
    include profiles::publiq::prototypes::deployment
  }

  # include ::profiles::publiq::prototypes::monitoring
  # include ::profiles::publiq::prototypes::metrics
  # include ::profiles::publiq::prototypes::logging
}
