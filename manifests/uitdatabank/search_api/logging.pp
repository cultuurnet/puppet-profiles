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
    input_type => 'log',
    paths      => ['/var/lib/docker/containers/*/*-json.log'],
    doc_type   => 'log',
    json       => {
      message_key   => 'log',
      add_error_key => true,
    },
    fields     => {
      log_type    => $app_log_type,
      environment => $environment,
    },
    processors => [
      {
        'add_docker_metadata' => {
          'host' => 'unix:///var/run/docker.sock',
        },
      },
    ],
    require    => Class['profiles::filebeat'],
  }

  # The corresponding Logstash filter/output for this log_type is
  # hand-maintained directly in infrastructure's logs-prod01 filter.conf/
  # output.conf, since the filter_fragment/concat collector mechanism used
  # for the access log above is never actually realized on the logstash
  # server (see the commented-out TODO). No fragment resource here to avoid
  # a second copy that can drift from the real one.
}
