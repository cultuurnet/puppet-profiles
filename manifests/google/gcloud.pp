define profiles::google::gcloud (
  Optional[String] $credentials_source = undef,
  Optional[String] $project            = undef
) {

  include ::profiles

  realize Apt::Source['publiq-tools']
  realize Package['google-cloud-cli']
  realize File['/etc/gcloud']

  if $credentials_source {
    file { "gcloud credentials ${title}":
      ensure  => 'file',
      path    => "/etc/gcloud/credentials_${title}.json",
      source  => $credentials_source,
      require => File['/etc/gcloud']
    }

    if $project {
      exec { "gcloud auth login for user ${title}":
        command     => "/usr/bin/gcloud auth login --cred-file=/etc/gcloud/credentials_${title}.json --project=${project}",
        user        => $title,
        refreshonly => true,
        subscribe   => [Package['google-cloud-cli'], File["gcloud credentials ${title}"]]
      }
    }
  }
}
