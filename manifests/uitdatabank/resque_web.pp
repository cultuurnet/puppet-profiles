class profiles::uitdatabank::resque_web (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases   = [],
  Stdlib::IP::Address::V4        $service_address = '127.0.0.1',
  Integer                        $service_port    = 5678,

) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']
  realize Apt::Source['publiq-tools']

  include profiles::apache
  include profiles::redis

  package { 'resque-web':
    ensure  => 'installed',
    require => Apt::Source['publiq-tools']
  }

  file { 'resque-web-service-defaults':
    ensure  => 'file',
    path    => '/etc/default/resque-web',
    content => "HOST=${service_address}\nPORT=${service_port}",
    notify  => Service['resque-web']
  }

  service { 'resque-web':
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    require   => Class['profiles::redis']
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    aliases             => $serveraliases,
    destination         => "http://${service_address}:${service_port}/",
    auth_openid_connect => true
  }
}
