# Collect Payara ODL logs for the central UiTPAS Logstash pipeline.
# By default all existing files are eligible; ignore_older optionally limits
# collection by file modification age, not by individual event timestamp.
class profiles::uitpas::api::logging (
  String           $servername,
  Optional[String] $ignore_older = undef
) inherits ::profiles {

  include profiles::filebeat

  filebeat::input { "${servername}_uitpas::api":
    input_type    => 'filestream',
    paths         => ['/opt/payara/glassfish/domains/uitpas/logs/server.log*'],
    exclude_files => ['\.gz$'],
    encoding      => 'utf-8',
    ignore_older  => $ignore_older,
    # Payara ODL records start with a timestamp; continuation lines belong
    # to the preceding event, including HTTP payloads and Java stack traces.
    multiline     => {
      'pattern'   => '^\[[0-9]{4}-[0-9]{2}-[0-9]{2}T',
      'negate'    => true,
      'match'     => 'after',
      'max_lines' => 2000,
      'timeout'   => '5s',
    },
    fields        => {
      log_type    => 'uitpas::api',
      environment => $environment,
      servername  => $servername,
    },
    require       => Class['profiles::filebeat'],
  }

  # Logstash parsing and output are managed in infrastructure's logs-prod01
  # configuration, rather than through exported filter fragments.
}
