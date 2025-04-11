class profiles::uitpas::groepspas (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases = [],
  Boolean                        $deployment    = true
) inherits ::profiles {

  $basedir = '/var/www/uitpas-groepspas'

  profiles::apache::vhost::basic { "http://${servername}":
    serveraliases => $serveraliases,
    documentroot  => $basedir
  }

  if $deployment {
    include profiles::uitpas::groepspas::deployment
  }

  # include ::profiles::uitpas::groepspas::monitoring
  # include ::profiles::uitpas::groepspas::metrics
  # include ::profiles::uitpas::groepspas::backup
  # include ::profiles::uitpas::groepspas::logging
}
