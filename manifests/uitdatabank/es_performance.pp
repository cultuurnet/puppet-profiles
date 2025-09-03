class profiles::uitdatabank::es_performance (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases            = [],
  Optional[String]               $elasticsearch_servername = undef,
) inherits ::profiles {


  include profiles::elasticsearch


  if $elasticsearch_servername {
    profiles::apache::vhost::reverse_proxy { "http://${elasticsearch_servername}":
      destination => 'http://127.0.0.1:9200/'
    }
  }
}
