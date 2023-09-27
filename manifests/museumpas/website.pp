class profiles::museumpas::website (
  String $mysql_version                      = undef,
  String $mysql_admin_user                   = 'admin',
  String $mysql_admin_password               = undef,
  String $mysql_host                         = undef,
  Hash $mysql_databases                      = undef,
  String $servername                         = undef,
  Boolean $install_meilisearch               = true,
  Boolean $install_redis                     = true,
  Boolean $deployment                        = true,
) inherits ::profiles {

  $basedir = '/var/www/museumpas'

  class { 'locales':
    default_locale  => 'en_US.UTF8',
    locales         => ['nl_BE.UTF8 UTF8', 'fr_BE.UTF8 UTF8', 'nl_NL.UTF8 UTF8', 'fr_FR.UTF8 UTF8'],
  }

  if $install_redis {
    include redis
    realize Firewall['400 accept REDIS traffic']
  }

  if $install_meilisearch {
    include profiles::meilisearch
    realize Firewall['400 accept MEILISEARCH traffic']
  }

  realize Firewall['300 accept HTTP traffic']

  include apache::mod::proxy
  include apache::mod::proxy_fcgi
  include apache::vhosts
  include profiles::firewall::rules

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
    rewrites          => [{
                           'comment' => 'Force all traffic (except Icinga checks) to HTTPS',
                           'rewrite_cond' => [
                              '%{HTTP:X-Forwarded-Proto} !https',
                              '%{HTTP_USER_AGENT} !^check_http',
                            ],
                            'rewrite_rule' => '^.*$ https://%{SERVER_NAME}%{REQUEST_URI} [R=301,NE,L]',
                         }],
    redirect_status   => 'permanent',
    redirect_source   => [ '/privacy' ],
    redirect_dest     => [ '/nl/voorwaarden-privacy-museumpas' ],
    setenv            => [ 'HTTPS "on"' ],
    setenvif          => [
                           'Remote_Addr "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+)" CLIENT_IP=$1',
                         ],
    require => [Class['profiles::apache']]
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

