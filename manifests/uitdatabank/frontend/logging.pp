class profiles::uitdatabank::frontend::logging (
  String $servername
) inherits ::profiles {

  include ::profiles::filebeat

  # Ships stdout/stderr from the frontend Docker container on this host.
  # Only included for the container deployment type, on nodes that run no
  # other containers, so the wildcard path picks up nothing else.
  $log_type = 'uitdatabank::frontend::app'

  filebeat::input { "${servername}_${log_type}":
    input_type => 'log',
    paths      => ['/var/lib/docker/containers/*/*-json.log'],
    doc_type   => 'log',
    json       => {
      message_key   => 'log',
      add_error_key => true,
    },
    fields     => {
      log_type    => $log_type,
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
