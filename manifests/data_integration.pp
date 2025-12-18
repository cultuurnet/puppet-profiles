class profiles::data_integration (
  Hash $sling_connections  = {},
  Hash $gcloud_credentials = {}
) inherits ::profiles {

  class { 'profiles::sling':
    connections => $sling_connections
  }

  $gcloud_credentials.each |String $name, Hash $properties| {
    profiles::google::gcloud::credentials { $name:
      * => $properties
    }
  }
}
