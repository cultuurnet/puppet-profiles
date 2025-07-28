class profiles::platform (
  String                        $servername,
  String                        $database_password,
  Variant[String,Array[String]] $serveraliases     = [],
  Boolean                       $deployment        = true,
  Boolean                       $catch_mail        = false,
  Boolean                       $sling_enabled     = false
) inherits ::profiles {

  $basedir       = '/var/www/platform-api'
  $database_name = 'platform'
  $database_user = 'platform'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::apache
  include ::profiles::php
  include ::profiles::mysql::server

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']]
  }

  mysql_database { $database_name:
    charset => 'utf8mb4',
    collate => 'utf8mb4_unicode_ci',
    require => Class['profiles::mysql::server']
  }

  profiles::mysql::app_user { "${database_user}@${database_name}":
    password => $database_password,
    remote   => true,
    require  => Mysql_database[$database_name]
  }

  profiles::apache::vhost::php_fpm { "http://${servername}":
    basedir              => $basedir,
    public_web_directory => 'public',
    aliases              => $serveraliases
  }

  if $catch_mail {
    class { 'profiles::mailpit':
      smtp_address => '127.0.0.1',
      smtp_port    => 1025,
      http_address => '127.0.0.1',
      http_port    => 8025
    }
  }

  if $deployment {
    class { 'profiles::platform::deployment':
      require   => Profiles::Mysql::App_user["${database_user}@${database_name}"],
      subscribe => Class['profiles::php']
    }
  }

  if $sling_enabled {
    class { 'profiles::sling':
      version                 => 'latest',
      database_name           => 'platform'
     }
  }
}
