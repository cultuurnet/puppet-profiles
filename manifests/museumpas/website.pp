class profiles::museumpas::website (
  String $database_password,
  String $database_host                           = '127.0.0.1',
  String $servername                              = undef,
  Variant[String, Array[String]] $serveraliases   = [],
  Variant[String, Array[String]] $image_libraries = ['jpegoptim', 'optipng', 'pngquant', 'gifsicle'],
  Boolean $deployment                             = true
) inherits ::profiles {

  $basedir = '/var/www/museumpas'

  $database_name = 'museumpas'
  $database_user = 'museumpas'

  include apache::mod::proxy
  include apache::mod::proxy_fcgi
  include apache::mod::rewrite
  include apache::vhosts
  include profiles::firewall::rules

  $image_libraries.each |$image_library| {
    package { $image_library:
      ensure => 'present'
    }
  }

  if $database_host == '127.0.0.1' {
    $database_host_remote    = false
    $database_host_available = true

    Class['profiles::mysql::server'] -> Mysql_database[$database_name]

  } else {
    $database_host_remote    = true

    if $facts['mysqld_version'] {
      $database_host_available = true

      class { "profiles::mysql::remote_server":
        host => $database_host
      } -> Mysql_database[$database_name]
    } else {
      $database_host_available = false
    }
  }

  if $database_host_available {
    mysql_database { $database_name:
      charset => 'utf8mb4',
      collate => 'utf8mb4_0900_ai_ci'
    }

    profiles::mysql::app_user { $database_user:
      database => $database_name,
      password => $database_password,
      remote   => $database_host_remote,
      require  => Mysql_database[$database_name]
    }
  }

  class { 'locales':
    default_locale  => 'en_US.UTF-8',
    locales         => ['en_US.UTF-8 UTF-8', 'nl_BE.UTF-8 UTF-8', 'fr_BE.UTF-8 UTF-8', 'nl_NL.UTF-8 UTF-8', 'fr_FR.UTF-8 UTF-8'],
  }

  class { "apache::mod::expires":
    expires_by_type => [
      'image/gif'              => 'access plus 1 month',
      'image/png'              => 'access plus 1 month',
      'image/jpg'              => 'access plus 1 month',
      'image/jpeg'             => 'access plus 1 month',
      'image/webp'             => 'access plus 1 month',
      'image/svg+xml'          => 'access plus 1 month',
      'text/css'               => 'access plus 1 month',
      'text/javascript'        => 'access plus 1 month',
      'font/woff2'             => 'access plus 1 month',
      'application/javascript' => 'access plus 1 month',
    ]
  }

  realize Firewall['300 accept HTTP traffic']

  apache::vhost { "${servername}_80":
    servername        => $servername,
    serveraliases     => [$serveraliases].flatten,
    docroot           => "${basedir}/public",
    manage_docroot    => false,
    request_headers   => [
                         'unset Proxy early'
                         ],
    port              => 80,
    access_log_format => 'extended_json',
    directories       => [{
                           path            => '\.php$',
                           provider        => 'filesmatch',
                           custom_fragment => 'SetHandler "proxy:unix:/var/run/php/php-fpm.sock|fcgi://localhost"',
                         },
                         {
                           path            => "${basedir}/public",
                           options         => [
                                                'Indexes',
                                                'FollowSymLinks',
                                                'MultiViews',
                                                'ExecCGI',
                                              ],
                           allow_override  => [ 'All' ],
                           headers         => [
                                                'always set Strict-Transport-Security "max-age=3153600; includeSubdomains;"',
                                                'always set X-Frame-Options "SAMEORIGIN"',
                                                'set X-XSS-Protection "1; mode=block"',
                                                'set X-Content-Type-Options "nosniff"',
                                              ]
                         }],
    redirect_status   => 'permanent',
    redirect_source   => [ '/privacy' ],
    redirect_dest     => [ '/nl/voorwaarden-privacy-museumpas' ],
    setenvif          => [
                           'X-Forwarded-Proto "https" HTTPS=on',
                           'X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+)" CLIENT_IP=$1',
                         ],
    require           => Class['profiles::apache']
  }

  if $deployment {
    include profiles::museumpas::website::deployment

    Class['profiles::php'] -> Class['profiles::museumpas::website::deployment']
    Class['profiles::museumpas::website::deployment'] -> Apache::Vhost["${servername}_80"]
  }
}
