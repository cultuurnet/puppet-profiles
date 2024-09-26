class profiles::atlassian::confluence (
  String                     $servername,
  String                     $version,
  String                     $java_opts,
  String                     $database_password,
  String                     $database_host     = '127.0.0.1',
  Boolean                    $lvm               = false,
  Optional[String]           $volume_group      = undef,
  Optional[String]           $volume_size       = undef,
  Boolean                    $manage_homedir    = false,
  Array                      $serveraliases     = [],
  String                     $initial_heap_size = '1024m',
  String                     $maximum_heap_size = '1024m'
) inherits ::profiles {

  $database_user = 'confluenceuser'
  $database_name = 'confluencedb'
  $dburl_params  = 'sessionVariables=transaction_isolation=READ-COMMITTED'
  $dburl         = "jdbc:mysql://${database_host}:3306/${$database_name}?${dburl_params}"

  if $database_host == '127.0.0.1' {
    $database_host_remote    = false
  } else {
    $database_host_remote    = true
  }

  include ::profiles::java
  include ::profiles::apache

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination         => 'http://127.0.0.1:8090/',
    aliases             => $serveraliases,
    auth_openid_connect => true
  }

  realize Group['confluence']
  realize User['confluence']

  # setup storage
  if ($lvm == true) and ($manage_homedir == false) {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'confluence_homedir':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/home/confluence',
      fs_type      => 'ext4',
      owner        => 'confluence',
      group        => 'confluence',
      require      => [Group['confluence'], User['confluence']]
    }
  } else {
    file { $homedir:
      ensure  => 'directory',
      owner   => 'confluence',
      group   => 'confluence',
      require => [Group['confluence'], User['confluence']]
    }
  }

  # configure database
  mysql_database { $database_name:
    charset => 'utf8mb4',
    collate => 'utf8mb4_0900_ai_ci'
  }

  profiles::mysql::app_user { "${database_user}@${database_name}":
    password => $database_password,
    remote   => $database_host_remote,
    require  => Mysql_database[$database_name]
  }

  # install confluence
  class { 'confluence':
    version                 => $version,
    installdir              => '/opt/confluence',
    homedir                 => '/home/confluence',
    tomcat_port             => 8090,
    manage_user             => false,
    javahome                => '/usr/lib/jvm/java-17-openjdk-amd64',
    jvm_type                => 'openjdk-17',
    mysql_connector         => false,
    jvm_xms                 => $initial_heap_size,
    jvm_xmx                 => $maximum_heap_size,
    java_opts               => $java_opts,
    manage_service          => true,
    tomcat_proxy            => {
                              proxyName  => $servername,
                              proxyPort  => '443',
                              scheme     => 'https'
                            }
  }

  $config = {
    'hibernate.connection.url'          => $dburl,
    'hibernate.connection.username'     => $database_user,
    'hibernate.connection.password'     => $database_password,
    'hibernate.connection.driver_class' => 'com.mysql.cj.jdbc.Driver'
  }

  $config.each |$key, $value| {
    confluence::conf { $key:
      value   => $value,
      require => Class[confluence]
    }
  }

  file { 'Confluence mysql-connector-j':
    ensure  => 'link',
    path    => "/opt/confluence/atlassian-confluence-${version}/confluence/WEB-INF/lib/mysql-connector-j.jar",
    source  => '/usr/share/java/mysql-connector-j.jar',
    require => [Package['mysql-connector-j'],Class['confluence']]
  }

  # include ::profiles::atlassian::confluence::monitoring
  # include ::profiles::atlassian::confluence::metrics
  # include ::profiles::atlassian::confluence::backup
  # include ::profiles::atlassian::confluence::logging
}
