class profiles::publiq::prototypes (
  Stdlib::Httpurl $url,
  Boolean         $deployment = true
) inherits ::profiles {

  $basedir    = '/var/www/prototypes'
  $servername = split($url, '/')[-1]

  profiles::apache::vhost::basic { $url:
    documentroot         => $basedir,
    serveraliases        => ["*.${servername}"],
    virtual_documentroot => "${basedir}/%1"
  }

  if $deployment {
    include profiles::publiq::prototypes::deployment
  }

  # include ::profiles::publiq::prototypes::monitoring
  # include ::profiles::publiq::prototypes::metrics
  # include ::profiles::publiq::prototypes::logging
}
