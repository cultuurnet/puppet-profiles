class profiles::platform (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases = [],
  Boolean                       $deployment    = true
) inherits ::profiles {

  $basedir = '/var/www/platform-api'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::apache
  include ::profiles::php

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']]
  }

  profiles::apache::vhost::php_fpm { "http://${servername}":
    basedir              => $basedir,
    public_web_directory => 'public',
    aliases              => $serveraliases
  }

  if $deployment {
    class { 'profiles::platform::deployment':
      subscribe => Class['profiles::php']
    }
  }
}
