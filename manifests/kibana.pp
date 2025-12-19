class profiles::kibana (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases   = [],
  String                         $version         = 'latest',
  Stdlib::IP::Address::V4        $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged     $service_port    = 5601,
  Enum['running', 'stopped']     $service_status  = 'running'
) inherits ::profiles {

  include ::profiles::apache

  $kibana_default_config = { 'logging' => { 'appenders' => { 'file' => { 'type' => 'file', 'fileName' => '/var/log/kibana/kibana.log', 'layout' => { 'type' => 'json' } } }, 'root' => { 'appenders' => ['default', 'file'] } }, 'pid.file' => '/run/kibana/kibana.pid' }
  $kibana_config         = { 'server.port' => $service_port, 'server.host' => "${service_address}" }


  realize Group['kibana']
  realize User['kibana']

  realize Apt::Source['elastic-8.x']

  package { 'kibana':
    ensure  => $version,
    require => [Apt::Source['elastic-8.x'], Group['kibana'], User['kibana']]
  }

  file { 'kibana config':
    ensure  => 'file',
    path    => '/etc/kibana/kibana.yml',
    content => to_yaml($kibana_default_config + $kibana_config),
    require => Package['kibana'],
    notify  => Service['kibana']
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination         => "http://${service_address}:${service_port}/",
    aliases             => $serveraliases,
    preserve_host       => true,
    auth_openid_connect => true
  }

  service { 'kibana':
    ensure    => $service_status,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    hasstatus => true,
    subscribe => Package['kibana']
  }
}
