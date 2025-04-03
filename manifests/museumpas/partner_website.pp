class profiles::museumpas::partner_website (
  String $database_password,
  String $database_host                           = '127.0.0.1',
  String $servername                              = undef,
  Variant[String, Array[String]] $serveraliases   = [],
  Boolean $deployment                             = true
) inherits ::profiles {

  $basedir = '/var/www/museumpas-partner'

  $database_name = 'museumpaspartner'
  $database_user = 'museumpaspartner'

  include apache::mod::proxy
  include apache::mod::proxy_fcgi
  include apache::mod::rewrite
  include apache::vhosts
  include profiles::firewall::rules
  include profiles::php

  if $database_host == '127.0.0.1' {
    $database_host_remote    = false
    $database_host_available = true

    include profiles::mysql::server

    Class['profiles::mysql::server'] -> Mysql_database[$database_name]
  } else {
    $database_host_remote = true

    class { 'profiles::mysql::remote_server':
      host => $database_host
    }

    if $facts['mysqld_version'] {
      $database_host_available = true
    } else {
      $database_host_available = false
    }
  }

  if $database_host_available {
    mysql_database { $database_name:
      charset => 'utf8mb4',
      collate => 'utf8mb4_0900_ai_ci',
    }

    profiles::mysql::app_user { $database_user:
      database => $database_name,
      password => $database_password,
      remote   => $database_host_remote,
      require  => Mysql_database[$database_name]
    }
  }

  profiles::apache::vhost::php_fpm { "http://${servername}":
    basedir              => $basedir,
    public_web_directory => 'web',
    aliases              => $serveraliases
  }

  if $deployment {
    include profiles::museumpas::partner_website::deployment

    Class['profiles::php'] ~> Class['profiles::museumpas::partner_website::deployment']
    Class['profiles::museumpas::partner_website::deployment'] -> Apache::Vhost["${servername}_80"]
  }
}
