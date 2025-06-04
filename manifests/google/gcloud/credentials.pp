define profiles::google::gcloud::credentials (
  String $project_id,
  String $private_key_id,
  String $private_key,
  String $client_id,
  String $client_email
) {

  include ::profiles

  realize File['/etc/gcloud']

  file { "gcloud credentials ${title}":
    ensure  => 'file',
    path    => "/etc/gcloud/credentials_${title}.json",
    content => template('profiles/google/gcloud/credentials.json.erb'),
    require => File['/etc/gcloud']
  }
}
