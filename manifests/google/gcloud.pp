define profiles::google::gcloud (
  Hash $credentials
) {

  include ::profiles

  realize Apt::Source['publiq-tools']
  realize Package['google-cloud-cli']

  profiles::google::gcloud::credentials { $title:
    * => $credentials
  }

  if $credentials['project_id'] {
    exec { "gcloud auth login for user ${title}":
      command     => "/usr/bin/gcloud auth login --cred-file=/etc/gcloud/credentials_${title}.json --project=${credentials['project_id']}",
      user        => $title,
      refreshonly => true,
      subscribe   => [Package['google-cloud-cli'], Profiles::Google::Gcloud::Credentials[$title]]
    }
  }
}
