class profiles::redis::container (
  String                  $container_name   = 'redis',
  String                  $image            = 'redis',
  String                  $image_tag        = '7-alpine',
  Stdlib::IP::Address::V4 $listen_address   = '127.0.0.1',
  Optional[String]        $maxmemory        = undef,
  Optional[String]        $maxmemory_policy = undef
) inherits ::profiles {

  include profiles::docker

  # Stop the native install so it doesn't fight the container for port 6379.
  service { 'redis-server':
    ensure => stopped,
    enable => false,
  }

  $maxmemory_args        = $maxmemory ? { undef => [], default => ['--maxmemory', $maxmemory] }
  $maxmemory_policy_args = $maxmemory_policy ? { undef => [], default => ['--maxmemory-policy', $maxmemory_policy] }

  $command_parts = ['redis-server', '--bind', $listen_address]
    + $maxmemory_args
    + $maxmemory_policy_args

  docker::run { $container_name:
    image            => "${image}:${image_tag}",
    net              => 'host',
    command          => join($command_parts, ' '),
    health_check_cmd => "nc -z ${listen_address} 6379",
    require          => [Class['profiles::docker'], Service['redis-server']],
  }
}
