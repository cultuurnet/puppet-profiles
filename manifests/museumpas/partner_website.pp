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

  if $database_host == '127.0.0.1' {
    $database_host_remote    = false

    Class['profiles::mysql::server'] -> Mysql_database[$database_name]
  } else {
    $database_host_remote    = true
    class { "profiles::mysql::remote_server":
      host => $database_host
    }
  }

  if $facts['mysqld_version'] {
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

  realize Firewall['300 accept HTTP traffic']

  apache::vhost { "${servername}_80":
    servername        => $servername,
    serveraliases     => [$serveraliases].flatten,
    docroot           => "${basedir}/web",
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
                           path            => "${basedir}/web",
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
    setenvif          => [
                           'X-Forwarded-Proto "https" HTTPS=on',
                           'X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+)" CLIENT_IP=$1',
                         ],
    require           => Class['profiles::apache']
  }

  if $deployment {
    include profiles::museumpas::partner_website::deployment

    Class['profiles::php'] -> Class['profiles::museumpas::partner_website::deployment']
    Class['profiles::museumpas::partner_website::deployment'] -> Apache::Vhost["${servername}_80"]
  }
}
