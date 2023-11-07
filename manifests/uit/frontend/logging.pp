class profiles::uit::frontend::logging (
  String $servername,
  String $log_type
) inherits ::profiles {

  include ::profiles::filebeat

  filebeat::input { "${servername}_filebeat_input":
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

  if $settings::storeconfigs {
    @@profiles::logstash::filter_fragment { "${servername}_${log_type}_${environment}":
      log_type => $log_type,
      filter   => file('profiles/uit/frontend/logstash_filter')
    }

    # TODO: Add this to the logstash server
    #
    # Profiles::Logstash::Filter_fragment <<| |>>
  }
}
