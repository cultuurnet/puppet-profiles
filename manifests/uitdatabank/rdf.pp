class profiles::uitdatabank::rdf (
  String          $servername,
  Stdlib::HTTPUrl $sparql_url = 'http://127.0.0.1:8080/'
) inherits ::profiles {

  include ::profiles::firewall::rules
  include ::profiles::apache

  $port            = 80
  $transport       = 'http'
  $request_headers = [
                       'unset Proxy early',
                       'set X-Unique-Id %{UNIQUE_ID}e',
                       "setifempty X-Forwarded-Port \"${port}\"",
                       "setifempty X-Forwarded-Proto \"${transport}\""
                     ]
  $rewrites        = [ {
                         comment      => 'Reverse proxy /(events|places|organizers)/<uuid> to Jena Fuseki backend with ?graph= query string',
                         rewrite_cond => [
                                           '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                           '%{REQUEST_URI} "^/(events|places|organizers)/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                         ],
                         rewrite_rule => "^/(events|places|organizers)/(.*)\$ ${sparql_url}\$1/?graph=https://%{HTTP_HOST}/\$1/\$2.ttl [P]"
                     } ]

  realize Firewall['300 accept HTTP traffic']

  apache::vhost { "${servername}_${port}":
    servername        => $servername,
    docroot           => '/var/www/html',
    manage_docroot    => false,
    port              => $port,
    access_log_format => 'combined_json',
    request_headers   => $request_headers,
    rewrites          => $rewrites,
    proxy_pass        => {
                           'path'         => '/',
                           'url'          => $sparql_url,
                           'keywords'     => [],
                           'reverse_urls' => $sparql_url,
                           'params'       => {}
                         }
  }

  # include ::profiles::uitdatabank::rdf::monitoring
  # include ::profiles::uitdatabank::rdf::metrics
  # include ::profiles::uitdatabank::rdf::backup
  # include ::profiles::uitdatabank::rdf::logging
}
