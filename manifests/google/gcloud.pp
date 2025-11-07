define profiles::google::gcloud (
  Hash    $credentials = {},
  Boolean $login       = true
) {

  include ::profiles

  realize Apt::Source['publiq-tools']
  realize Package['google-cloud-cli']

  unless $credentials.empty {
    profiles::google::gcloud::credentials { $title:
      * => $credentials
    }
  }

  if ($login and $credentials['project_id']) {
    exec { "gcloud auth login for ${title}":
      command     => "/usr/bin/gcloud auth login --cred-file=/etc/gcloud/credentials_${title}.json --project=${credentials['project_id']}",
      user        => $title,
      refreshonly => true,
      subscribe   => [Package['google-cloud-cli'], Profiles::Google::Gcloud::Credentials[$title]]
    }
  }
}
