class profiles::uit::frontend::logging (
  String  $servername,
  String  $log_type,
  String  $environment
) inherits ::profiles {

  include ::profiles::filebeat

  filebeat::input { "${servername}_filebeat_input":
    paths    => [ "/var/log/apache2/${servername}_80_access.log" ],
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
    require => Class['profiles::filebeat']
  }

#   if $settings::storeconfigs {
#     @@logstash_filter { ${servername}_logstash_filter:
#       log_type    => $log_type,
#       environment => $environment
#     }
# 
#     # TODO: Add this to the logstash server
#     #
#     # Logstash_filter <<| |>>
#   }
}
