class profiles::uit::cms (
  String                        $servername,
  Stdlib::Httpurl               $frontend_url,
  String                        $database_password,
  Variant[String,Array[String]] $serveraliases     = [],
  Boolean                       $deployment        = true,
  Boolean                       $lvm               = false,
  Optional[String]              $volume_group      = undef,
  Optional[String]              $volume_size       = undef
) inherits ::profiles {

  $basedir       = '/var/www/uit-cms'
  $database_user = 'uit_cms'
  $database_name = 'uit_cms'

  realize Group['www-data']
  realize User['www-data']
  realize Firewall['300 accept HTTP traffic']

  include ::profiles::firewall::rules
  include ::profiles::php
  include ::profiles::redis
  include ::profiles::mysql::server
  include ::profiles::apache

  file { [$basedir, "${basedir}/web", "${basedir}/web/sites", "${basedir}/web/sites/default", "${basedir}/web/sites/default/files"]:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']]
  }

  file { 'hostnames.txt':
    ensure  => 'file',
    path    => "${basedir}/hostnames.txt",
    owner   => 'www-data',
    group   => 'www-data',
    content => "${servername} ${frontend_url}",
    require => [Group['www-data'], User['www-data']],
    before  => Profiles::Apache::Vhost::Php_fpm["http://${servername}"]
  }

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'cmsdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/cms',
      fs_type      => 'ext4',
      owner        => 'www-data',
      group        => 'www-data',
      require      => [Group['www-data'], User['www-data']]
    }

    mount { "${basedir}/web/sites/default/files":
      ensure  => 'mounted',
      device  => '/data/cms',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['cmsdata'], File["${basedir}/web/sites/default/files"]]
    }
  }

  mysql_database { 'uit_cms':
    charset => 'utf8mb4',
    collate => 'utf8mb4_unicode_ci',
    require => Class['profiles::mysql::server']
  }

  profiles::mysql::app_user { $database_user:
    database => $database_name,
    password => $database_password,
    require  => Mysql_database[$database_name]
  }

  if $deployment {
    include profiles::uit::cms::deployment

    Class['profiles::php'] -> Class['profiles::uit::cms::deployment']
    Class['profiles::redis'] -> Class['profiles::uit::cms::deployment']
    Class['profiles::mysql::server'] -> Class['profiles::uit::cms::deployment']
    Mysql_database['uit_cms'] -> Class['profiles::uit::cms::deployment']
    Profiles::Mysql::App_user[$database_user] -> Class['profiles::uit::cms::deployment']
    File["${basedir}/web/sites/default/files"] -> Class['profiles::uit::cms::deployment']
    Class['profiles::uit::cms::deployment'] -> Profiles::Apache::Vhost::Php_fpm["http://${servername}"]

    if $lvm {
      Mount["${basedir}/web/sites/default/files"] -> Class['profiles::uit::cms::deployment']
    }
  }

  profiles::apache::vhost::php_fpm { "http://${servername}":
    basedir              => $basedir,
    public_web_directory => 'web',
    aliases              => $serveraliases,
    rewrites             => [ {
                                comment      => 'Redirect all requests to /tip/ to the frontend vhost',
                                rewrite_map  => "hostnames 'txt:/var/www/uit-cms/hostnames.txt'",
                                rewrite_rule => '^/tip/(.*)$ ${hostnames:%{HTTP_HOST}}/tip/$1 [R=301,NE,L]'
                            } ]
  }

  # include ::profiles::uit::cms::logging
  # include ::profiles::uit::cms::monitoring
  # include ::profiles::uit::cms::metrics
  # include ::profiles::uit::cms::backup
}
