class profiles::data_integration (
  Hash $sling_connections  = {},
  Hash $gcloud_credentials = {}
) inherits ::profiles {

  class { 'profiles::sling':
    connections => $sling_connections
  }

  unless empty($gcloud_credentials) {
    profiles::google::gcloud::credentials { 'sling':
      * => $gcloud_credentials
    }
  }
}
