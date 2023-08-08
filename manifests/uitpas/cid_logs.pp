class profiles::uitpas::cid_logs (
  String                        $hostname        = 'cidlogs.publiq.be',
  Variant[String,Array[String]] $aliases         = 'cidmonitor.lodgon.com',
  Stdlib::Ipv4                  $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged    $service_port    = 8080,
  String                        $data_dir        = '/data/cidlogs',
  String                        $gcs_credentials
) inherits ::profiles {

  realize Group['logstash']
  realize User['logstash']

  profiles::apache::vhost::reverse_proxy { "http://${hostname}":
    destination => "http://${service_address}:${service_port}/",
    aliases     => $aliases
  }

  class { '::apache::mod::prefork':
    serverlimit => 512,
    maxclients  => 512,
  }

  file { 'gcs_credentials':
    ensure  => 'file',
    path    => '/etc/logstash/gcs_credentials.json',
    owner   => 'logstash',
    group   => 'logstash',
    mode    => '0640',
    source  => $gcs_credentials,
    require => [User['logstash'], Package['logstash']],
    notify  => Service['logstash']
  }

  file { $data_dir:
    ensure => 'directory',
    owner  => 'logstash',
    group  => 'logstash',
    mode   => '0755',
    require => [User['logstash'], Package['logstash']]
  }

  cron { 'remove-old-cidlogs':
    command     => "/usr/bin/find ${data_dir} -type f -name '*.log' -mtime +30 -delete",
    environment => [ 'MAILTO=infra@publiq.be' ],
    user        => 'root',
    hour        => '3',
    minute      => '30',
    require     => File[$data_dir]
  }
}
