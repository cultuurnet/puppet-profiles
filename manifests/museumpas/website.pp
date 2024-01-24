class profiles::museumpas::website (
  String $mysql_version                         = undef,
  String $mysql_admin_user                      = 'admin',
  String $mysql_admin_password                  = undef,
  String $mysql_host                            = undef,
  Hash $mysql_databases                         = undef,
  String $servername                            = undef,
  Variant[String, Array[String]] $serveraliases = [],
  Boolean $install_meilisearch                  = true,
  Boolean $install_redis                        = true,
  Boolean $deployment                           = true
) inherits ::profiles {

  $basedir = '/var/www/museumpas'

  include apache::mod::proxy
  include apache::mod::proxy_fcgi
  include apache::mod::rewrite
  include apache::vhosts
  include profiles::firewall::rules

  if $install_redis {
    include redis
    realize Firewall['400 accept redis traffic']
  }

  if $install_meilisearch {
    include profiles::meilisearch
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

  file { 'mysqld_version_ext_fact':
    ensure  => 'file',
    path    => '/etc/puppetlabs/facter/facts.d/mysqld_version.txt',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "mysqld_version=${mysql_version}"
  }

  file { 'root_my_cnf':
    ensure  => 'file',
    path    => '/root/.my.cnf',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('profiles/museumpas/website/my.cnf.erb'),
    require  => [File['mysqld_version_ext_fact']]
  }

  $mysql_databases.each |$name,$properties| {
    mysql::db { $name:
      user     => $properties['user'],
      password => $properties['password'],
      host     => $properties['host'],
      require  => [File['root_my_cnf']]
    }
  }

  if $deployment {
    include profiles::museumpas::website::deployment

    Class['profiles::php'] -> Class['profiles::museumpas::website::deployment']
    Class['profiles::museumpas::website::deployment'] -> Apache::Vhost["${servername}_80"]
  }
}
