class profiles::uit::recommender_frontend (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases = [],
  Boolean                       $deployment    = true,
  Integer                       $service_port  = 6000
)  inherits ::profiles {

  include ::profiles::nodejs

  if $deployment {
    class { 'profiles::uit::recommender_frontend::deployment':
      service_port => $service_port
    }

    Class['profiles::nodejs'] -> Class['profiles::uit::recommender_frontend::deployment']
    Class['profiles::uit::recommender_frontend::deployment'] -> Profiles::Apache::Vhost::Reverse_proxy["http://${servername}"]
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination => "http://127.0.0.1:${service_port}/",
    aliases     => $serveraliases
  }

  # include ::profiles::uit::recommender_frontend::monitoring
  # include ::profiles::uit::recommender_frontend::metrics
  # include ::profiles::uit::recommender_frontend::backup
  # include ::profiles::uit::recommender_frontend::logging
}
