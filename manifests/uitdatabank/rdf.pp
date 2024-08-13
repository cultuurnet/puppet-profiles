class profiles::uitdatabank::rdf (
  String          $servername,
  Stdlib::HTTPUrl $backend_url
) inherits ::profiles {

  include ::profiles::firewall::rules
  include ::profiles::apache

  $port                  = 80
  $transport             = 'http'
  $backend_url_sanitized = regsubst($backend_url, '/$', '')
  $request_headers       = [
                             'unset Proxy early',
                             'set X-Unique-Id %{UNIQUE_ID}e',
                             "setifempty X-Forwarded-Port \"${port}\"",
                             "setifempty X-Forwarded-Proto \"${transport}\"",
                             'set Accept "text/turtle"'
                           ]
  $rewrites              = [ {
                             comment      => 'Reverse proxy /(events|places|organizers)/<uuid> to backend',
                             rewrite_cond => [
                                               '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                               '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                             ],
                             rewrite_rule => "^/(events|places|organizers)/(.*)\$ ${backend_url_sanitized}/\$1/\$2 [P]"
                           }, {
                             comment      => 'Reverse proxy /id/(event|place|organizer)/udb/<uuid> to backend',
                             rewrite_cond => [
                                               '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                               '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                             ],
                             rewrite_rule => "^/id/(event|place|organizer)/udb/(.*)\$ ${backend_url_sanitized}/\$1s/\$2 [P]"
                           } ]

  if $backend_url =~ /^https/ {
    $https_backend = true

    include apache::mod::ssl

    Class['apache::mod::ssl'] -> Apache::Vhost["${servername}_${port}"]
  } else {
    $https_backend = false
  }

  realize Firewall['300 accept HTTP traffic']

  include apache::mod::proxy
  include apache::mod::proxy_http

  apache::vhost { "${servername}_${port}":
    servername        => $servername,
    docroot           => '/var/www/html',
    manage_docroot    => false,
    port              => $port,
    access_log_format => 'extended_json',
    ssl_proxyengine   => $https_backend,
    request_headers   => $request_headers,
    rewrites          => $rewrites,
    setenvif          => [
                           'X-Forwarded-Proto "https" HTTPS=on',
                           'X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+).*" CLIENT_IP=$1'
                         ],
    require           => [Class['apache::mod::proxy'], Class['apache::mod::proxy_http']]
  }

  # include ::profiles::uitdatabank::rdf::monitoring
  # include ::profiles::uitdatabank::rdf::metrics
  # include ::profiles::uitdatabank::rdf::backup
  # include ::profiles::uitdatabank::rdf::logging
}
