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

  $basedir = '/var/www/uit-cms'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::firewall::rules
  include ::profiles::php
  include ::profiles::redis
  include ::profiles::mysql::server
  include ::profiles::apache

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']],
  }

  file { "${basedir}/hostnames.txt":
    ensure  => 'file',
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
      require      => [Group['www-data'], User['www-data']],
      before       => Package['uit-cms']
    }

    file { "${basedir}/web":
      ensure => 'directory',
      owner  => 'www-data',
      group  => 'www-data'
    }

    file { "${basedir}/web/sites":
      ensure => 'directory',
      owner  => 'www-data',
      group  => 'www-data'
    }

    file { "${basedir}/web/sites/default":
      ensure => 'directory',
      owner  => 'www-data',
      group  => 'www-data'
    }

    file { "${basedir}/web/sites/default/files":
      ensure  => 'link',
      target  => '/data/cms',
      force   => true,
      owner   => 'www-data',
      group   => 'www-data',
      require => [File['/var/lib/jena-fuseki'], Profiles::Lvm::Mount['cmsdata']]
    }
  }

  mysql_database { 'uit_cms':
    charset => 'utf8mb4',
    collate => 'utf8mb4_unicode_ci',
    require => Class['profiles::mysql::server']
  }

  mysql_user { 'uit_cms@127.0.0.1':
    ensure        => present,
    password_hash => mysql::password($database_password),
    require       => Class['profiles::mysql::server']
  }

  mysql_user { 'uit_cms@%':
    ensure        => present,
    password_hash => mysql::password($database_password),
    require       => Class['profiles::mysql::server']
  }

  mysql_grant { 'uit_cms@127.0.0.1/uit_cms.*':
    user       => 'uit_cms@127.0.0.1',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => 'uit_cms.*'
  }

  mysql_grant { 'uit_cms@%/uit_cms.*':
    user       => 'uit_cms@%',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => 'uit_cms.*'
  }

  if $deployment {
    include profiles::uit::cms::deployment

    Class['profiles::php'] -> Class['profiles::uit::cms::deployment']
    Class['profiles::redis'] -> Class['profiles::uit::cms::deployment']
    Class['profiles::mysql::server'] -> Class['profiles::uit::cms::deployment']
    Mysql_database['uit_cms'] -> Class['profiles::uit::cms::deployment']
    Mysql_user['uit_cms@127.0.0.1'] -> Class['profiles::uit::cms::deployment']
    Mysql_user['uit_cms@%'] -> Class['profiles::uit::cms::deployment']
    Mysql_grant['uit_cms@127.0.0.1/uit_cms.*'] -> Class['profiles::uit::cms::deployment']
    Mysql_grant['uit_cms@%/uit_cms.*'] -> Class['profiles::uit::cms::deployment']
    File["${basedir}/web/sites/default/files"] -> Class['profiles::uit::cms::deployment']
    Class['profiles::uit::cms::deployment'] -> Profiles::Apache::Vhost::Php_fpm["http://${servername}"]
  }

  realize Firewall['300 accept HTTP traffic']

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
