class profiles::uitdatabank::search_api::elasticdump_to_gcs (
  Optional[String] $project_id          = undef,
  Optional[String] $bucket_name         = undef,
  String           $bucket_dumplocation = '',
  Boolean          $dump_schedule       = false,
  Integer          $dump_hour           = 0,
  String           $local_timezone      = 'UTC'
) inherits ::profiles {

  if $project_id {
    $secrets = lookup('vault:uitdatabank/udb3-search-service')

    profiles::google::gcloud { 'root':
      credentials => {
                       project_id     => $project_id,
                       private_key_id => $secrets['gcloud_private_key_id'],
                       private_key    => $secrets['gcloud_private_key'],
                       client_id      => $secrets['gcloud_client_id'],
                       client_email   => $secrets['gcloud_client_email']
                     }
    }
  }

  if $bucket_name {
    file { 'elasticdump_to_gcs':
      ensure  => 'file',
      path    => '/usr/local/bin/elasticdump_to_gcs',
      content => template('profiles/uitdatabank/search_api/elasticdump_to_gcs.erb'),
      mode    => '0755',
      require => Profiles::Google::Gcloud['root']
    }

    cron { 'elasticdump_to_gcs':
      ensure      => $dump_schedule ? {
                       true  => 'present',
                       false => 'absent'
                     },
      command     => "/usr/bin/test $(date +\\%0H) -eq ${dump_hour} && /usr/local/bin/elasticdump_to_gcs /data/backup/elasticsearch/current/udb3_core_v*",
      environment => ['SHELL=/bin/bash', "TZ=${local_timezone}", 'MAILTO=infra+cron@publiq.be'],
      hour        => '*',
      minute      => '00',
      require     => File['elasticdump_to_gcs']
    }
  }
}
