class profiles::uitdatabank::entry_api::logging (
  String                        $servername,
  Enum['instance', 'container'] $type = 'instance'
) inherits ::profiles {

  $log_type = 'uitdatabank::entry_api::access'

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
    filter   => file('profiles/uitdatabank/entry_api/logstash_filter_access.conf'),
    tag      => $environment
  }

  # TODO: Add this to the logstash server
  #
  # if $settings::storeconfigs {
  #   Profiles::Logstash::Filter_fragment <<| |>>
  # }

  # Ships stdout/stderr from the entry-api Docker containers on this host
  # (entry-api, entry-nginx, the workers and the amqp listener). Only declared
  # for the container deployment type, on nodes that run no other containers,
  # so the wildcard path picks up nothing else.
  if $type == 'container' {
    $app_log_type = 'uitdatabank::entry_api::app'

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
    # output.conf (see profiles::uitdatabank::search_api::logging).
  }
}
