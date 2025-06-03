class profiles::platform (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases = [],
  Boolean                       $deployment    = true,
  Boolean                       $sling_enabled = true
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
  if $sling_enabled {
    class { 'profiles::sling':
      version                 => 'latest',
      database_name           => 'platform',
      require                 => Class['profiles::mysql::server'],
    }
  }
}
