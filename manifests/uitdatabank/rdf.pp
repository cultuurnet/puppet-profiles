class profiles::uitdatabank::rdf (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases = [],
  Boolean                        $deployment    = true
) inherits ::profiles {

  $basedir = '/var/www/udb3-backend'

  include ::profiles::apache
  include ::profiles::redis
  include ::profiles::php

  $rewrites = [{
                comment      => 'Only allow GET requests',
                rewrite_cond => ['%{REQUEST_METHOD} !GET'],
                rewrite_rule => '^ - [F,L]'
              }, {
                comment      => 'Only allow requests to /(event|place|organizer)s?/<uuid> or /id/(event|place|organizer)/udb/<uuid>',
                rewrite_cond => [
                                  '%{REQUEST_URI} !^/(event|place|organizer)s?/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$',
                                  '%{REQUEST_URI} !^/(event|place|organizer)s?/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$',
                                  '%{REQUEST_URI} !^/id/(event|place|organizer)/udb/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$',
                                  '%{REQUEST_URI} !^/id/(event|place|organizer)/udb/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$'
                                ],
                rewrite_rule => '^ - [F,L]'
              }, {
                comment      => 'Reverse proxy /id/(event|place|organizer)/udb/<uuid> to backend',
                rewrite_cond => [
                                  '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$" [OR]',
                                  '%{REQUEST_URI} "^/id/(event|place|organizer)/udb/[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$"'
                                ],
                rewrite_rule => "^/id/(event|place|organizer)/udb/(.*)\$ %{HTTP:X-Forwarded-Proto}://${servername}/\$1s/\$2 [P]"
              }]

  profiles::apache::vhost::php_fpm { "http://${servername}":
    basedir               => $basedir,
    public_web_directory  => 'web',
    aliases               => [$serveraliases].flatten,
    allow_encoded_slashes => 'nodecode',
    access_log_format     => 'extended_json',
    request_headers       => [
                               'set Accept "text/turtle"'
                             ],
    rewrites              => $rewrites,
    ssl_proxyengine       => true
  }

  if $deployment {
    include profiles::uitdatabank::entry_api::deployment
  }

  # include ::profiles::uitdatabank::rdf::monitoring
  # include ::profiles::uitdatabank::rdf::metrics
  # include ::profiles::uitdatabank::rdf::backup
  # include ::profiles::uitdatabank::rdf::logging
}
