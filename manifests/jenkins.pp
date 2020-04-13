## This profile installs jenkins, adds plugins, and ....
class profiles::jenkins ()
{

  contain ::profiles

  # This will install aptly and set the s3_publish_endpoints parameter.
  class { 'jenkins':
  }

}
