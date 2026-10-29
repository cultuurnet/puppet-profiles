class profiles::uitpas::cid_logs (
  String                        $hostname,
  Variant[String,Array[String]] $aliases         = undef,
  Stdlib::IP::Address::V4       $service_address = '127.0.0.1',
  Stdlib::Port::Unprivileged    $service_port    = 8080,
  String                        $data_dir        = '/data/cidlogs',
  Boolean                       $lvm             = false,
  Optional[String]              $volume_group    = undef,
  Optional[String]              $volume_size     = undef,
  String                        $mountpoint      = $data_dir
) inherits ::profiles {

  $gcloud_credentials = lookup('data::google::gcloud_credentials')

  realize Group['logstash']
  realize User['logstash']

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'cidlogsdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => $mountpoint,
      fs_type      => 'ext4',
      owner        => 'logstash',
      group        => 'logstash',
      require      => [Group['logstash'], User['logstash']],
      before       => Service['logstash']
    }
  }

  profiles::apache::vhost::reverse_proxy { "http://${hostname}":
    destination => "http://${service_address}:${service_port}/",
    aliases     => $aliases,
    headers     => 'set Access-Control-Allow-Origin "*"'
  }

  profiles::google::gcloud::credentials { 'bigquery':
    * => $gcloud_credentials['bigquery']
  }

  unless $lvm and $mountpoint == $data_dir {
    file { $data_dir:
      ensure => 'directory',
      owner  => 'logstash',
      group  => 'logstash',
      mode   => '0755',
      require => [User['logstash'], Package['logstash']]
    }
  }

  cron { 'remove-old-cidlogs':
    command     => "/usr/bin/find ${data_dir} -type f -name '*.log' -mtime +30 -delete",
    environment => [ 'MAILTO=infra+cron@publiq.be' ],
    user        => 'root',
    hour        => '3',
    minute      => '30',
    require     => File[$data_dir]
  }
}
