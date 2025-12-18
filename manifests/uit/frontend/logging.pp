class profiles::uit::frontend::logging (
  String $servername
) inherits ::profiles {

  $log_type = 'uit::frontend::access'

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

  @@profiles::logstash::filter_fragment { "${servername}_${log_type}_${environment}":
    log_type => $log_type,
    filter   => file('profiles/uit/frontend/logstash_filter_access.conf'),
    tag      => $environment
  }

  # TODO: Add this to the logstash server
  #
  # if $settings::storeconfigs {
  #   Profiles::Logstash::Filter_fragment <<| |>>
  # }
}
