class profiles::uitdatabank::search_api::logging (
  String $servername
) inherits ::profiles {

  $log_type = 'uitdatabank::search_api::access'

  include ::profiles::filebeat

  filebeat::input { "${servername}_${log_type}":
    paths    => ["/var/log/apache2/${servername}_80_access.log"],
    doc_type => 'json',
    encoding => 'utf-8',
    json     => {
                  keys_under_root => true,
                  add_error_key   => true
                },
    fields   => {
                  log_type    => $log_type,
                  environment => $environment
                },
    require  => Class['profiles::filebeat']
  }

  @@profiles::logstash::filter_fragment { "${servername}_${log_type}":
    log_type => $log_type,
    filter   => file('profiles/uitdatabank/search_api/logstash_filter_access.conf'),
    tag      => $environment
  }

  # TODO: Add this to the logstash server
  #
  # if $settings::storeconfigs {
  #   Profiles::Logstash::Filter_fragment <<| |>>
  # }

  # Ships stdout/stderr from all search-api Docker containers on this host
  # (search-api, search-consume-udb3-api/cli/related). No-op on hosts that
  # don't run Docker containers, so it's safe to include unconditionally
  # regardless of deployment type (instance vs container).
  $app_log_type = 'uitdatabank::search_api::app'

  filebeat::input { "${servername}_${app_log_type}":
    input_type => 'docker',
    doc_type   => 'log',
    fields     => {
      log_type    => $app_log_type,
      environment => $environment,
    },
    require    => Class['profiles::filebeat'],
  }

  @@profiles::logstash::filter_fragment { "${servername}_${app_log_type}":
    log_type => $app_log_type,
    filter   => file('profiles/uitdatabank/search_api/logstash_filter_app.conf'),
    tag      => $environment,
  }
}
