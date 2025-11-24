class profiles::museumpas::website::logging (
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
}
