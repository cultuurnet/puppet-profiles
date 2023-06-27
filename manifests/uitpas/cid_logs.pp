class profiles::uitpas::cid_logs (
  String                        $hostname        = 'cidmonitor.lodgon.com',
  Variant[String,Array[String]] $aliases         = 'cidlogs.publiq.be',
  Stdlib::Ipv4                  $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged    $service_port    = 8080,
  String                        $data_dir        = '/data/cidlogs',
  String                        $gcs_credentials,
) inherits ::profiles {

  realize Group['logstash']
  realize User['logstash']

  profiles::apache::vhost::reverse_proxy { "http://${hostname}":
    destination => "http://${service_address}:${service_port}/",
    aliases     => $aliases
  }

  file { 'gcs_credentials':
    ensure  => 'file',
    path    => '/etc/logstash/gcs_credentials.json',
    owner   => 'logstash',
    group   => 'logstash',
    mode    => '0640',
    source  => $gcs_credentials,
    require => [User['logstash'],Package['logstash']],
    notify  => Service['logstash']
  }

  file { $data_dir:
    ensure => 'directory', 
    owner  => 'logstash',
    group  => 'logstash',
    mode   => '0755',
    require => [User['logstash'],Package['logstash']]
  }
}
