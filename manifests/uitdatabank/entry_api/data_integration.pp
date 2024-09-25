class profiles::uitdatabank::entry_api::data_integration (
  String           $database_name,
  Optional[String] $popularity_score_password = undef,
  Optional[String] $similar_events_password   = undef,
  Optional[String] $event_labeling_password   = undef,
  Optional[String] $duplicate_places_password = undef
) inherits ::profiles {

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
}
