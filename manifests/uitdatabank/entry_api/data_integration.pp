class profiles::uitdatabank::entry_api::data_integration (
  String           $database_name,
  String           $project_id,
  String           $bucket,
  String           $database_host             = '127.0.0.1',
  Optional[String] $popularity_score_password = undef,
  Optional[String] $similar_events_password   = undef,
  Optional[String] $event_labeling_password   = undef,
  Optional[String] $duplicate_places_password = undef,
  Optional[String] $jenkins_password          = undef,
  Optional[String] $developer_password        = undef
) inherits ::profiles {

  $secrets                        = lookup('vault:uitdatabank/udb3-backend')
  $ownership_search_password_seed = $facts['ec2_metadata'] ? {
                                      undef   => "${database_name}_ownership_search",
                                      default => join(["${database_name}_ownership_search", file($settings::hostprivkey)], "\n")
                                    }
  $ownership_search_password      = fqdn_rand_string(20, $ownership_search_password_seed)

  profiles::mysql::app_user { "ownership_search@${database_name}":
    tables   => ['ownership_search'],
    password => $ownership_search_password,
    readonly => true,
    remote   => false
  }

  profiles::google::gcloud { 'root':
    credentials => {
                     project_id     => $project_id,
                     private_key_id => $secrets['gcloud_private_key_id'],
                     private_key    => $secrets['gcloud_private_key'],
                     client_id      => $secrets['gcloud_client_id'],
                     client_email   => $secrets['gcloud_client_email']
                   }
  }

  profiles::sling::connection { $database_name:
    type          => 'mysql',
    configuration => {
                        user     => 'ownership_search',
                        password => $ownership_search_password,
                        host     => $database_host,
                        database => $database_name
                     },
    require       => Profiles::Mysql::App_user["ownership_search@${database_name}"]
  }

  profiles::sling::connection { 'ownership_search':
    type          => 'gs',
    configuration => {
                        bucket   => $bucket,
                        key_file => '/etc/gcloud/credentials_root.json',
                     },
    require       => Profiles::Google::Gcloud['root']
  }

  if $popularity_score_password {
    profiles::mysql::app_user { "popularity_score@${database_name}":
      tables   => ['offer_popularity'],
      password => $popularity_score_password,
      remote   => true
    }
  }

  if $similar_events_password {
    profiles::mysql::app_user { "similar_events@${database_name}":
      tables   => ['similar_events'],
      password => $similar_events_password,
      remote   => true
    }
  }

  if $event_labeling_password {
    profiles::mysql::app_user { "event_labeling@${database_name}":
      tables   => ['labels_import'],
      password => $event_labeling_password,
      remote   => true
    }
  }

  if $duplicate_places_password {
    profiles::mysql::app_user { "duplicate_places@${database_name}":
      tables   => ['duplicate_places_import', 'duplicate_places_removed_from_cluster_import'],
      password => $duplicate_places_password,
      remote   => true
    }
  }

  if $jenkins_password {
    profiles::mysql::app_user { "jenkins@${database_name}":
      password => $jenkins_password,
      readonly => true,
      remote   => true
    }
  }

  if $developer_password {
    profiles::mysql::app_user { "developer@${database_name}":
      password => $developer_password,
      readonly => true,
      remote   => true
    }
  }
}
