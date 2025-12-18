class profiles::grafana (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases   = [],
  String                         $version         = 'latest',
  Stdlib::IP::Address::V4        $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged     $service_port    = 3000,
  Enum['running', 'stopped']     $service_status  = 'running'
) inherits ::profiles {

  realize Group['grafana']
  realize User['grafana']

  realize Apt::Source['publiq-tools']

  include ::profiles::apache

  package { 'grafana':
    ensure  => $version,
    require => [Apt::Source['publiq-tools'], Group['grafana'], User['grafana']]
  }

  file { 'grafana config':
    ensure  => 'file',
    path    => '/etc/grafana/grafana.ini',
    content => "[server]\nprotocol = http\nhttp_addr = ${service_address}\nhttp_port = ${service_port}",
    require => Package['grafana'],
    notify  => Service['grafana-server']
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination   => "http://${service_address}:${service_port}/",
    aliases       => $serveraliases,
    preserve_host => true
  }

  service { 'grafana-server':
    ensure    => $service_status,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    hasstatus => true,
    subscribe => Package['grafana']
  }
}
