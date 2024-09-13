class profiles::uitdatabank::search_api::elasticdump_to_gcs (
  Optional[String] $project             = undef,
  Optional[String] $bucket_name         = undef,
  String           $bucket_dumplocation = '',
  Optional[String] $credentials_source  = undef,
  Boolean          $dump_schedule       = false,
  Integer          $dump_hour           = 0,
  String           $local_timezone      = 'UTC'
) inherits ::profiles {

  profiles::google::gcloud { 'root':
    credentials_source => $credentials_source,
    project            => $project
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
