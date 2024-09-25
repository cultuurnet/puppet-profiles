class profiles::atlassian::jira (
  String                     $servername,
  String                     $version,
  String                     $java_opts,
  String                     $database_password,
  String                     $database_host        = '127.0.0.1',
  Boolean                    $database_host_remote = false,
  Enum['running', 'stopped'] $service_status       = 'running',
  Boolean                    $lvm                  = false,
  Optional[String]           $volume_group         = undef,
  Optional[String]           $volume_size          = undef,
  Boolean                    $manage_homedir       = false,
  Array                      $serveraliases        = [],
  String                     $initial_heap_size    = '1024m',
  String                     $maximum_heap_size    = '1024m'
) inherits ::profiles {

  $database_user = 'jirauser'
  $database_name = 'jiradb'
  $dburl_params  = 'useUnicode=true&amp;characterEncoding=UTF8&amp;sessionVariables=default_storage_engine=InnoDB'
  $dburl         = "jdbc:mysql://${database_host}:3306/${$database_name}?${dburl_params}"

  include ::profiles::java
  include ::profiles::apache

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination         => 'http://127.0.0.1:8080/',
    aliases             => $serveraliases,
    auth_openid_connect => true
  }

  realize Group['jira']
  realize User['jira']

  # setup storage
  if ($lvm == true) and ($manage_homedir == false) {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'jira_homedir':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/home/jira',
      fs_type      => 'ext4',
      owner        => 'jira',
      group        => 'jira',
      require      => [Group['jira'], User['jira']]
    }
  } else {
    file { $homedir:
      ensure  => 'directory',
      owner   => 'jira',
      group   => 'jira',
      require => [Group['jira'], User['jira']]
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

  # install jira
  class { 'jira':
    version                => $version,
    installdir             => '/opt/jira',
    manage_homedir         => $manage_homedir,
    homedir                => '/home/jira',
    tomcat_port            => 8080,
    manage_user            => false,
    javahome               => '/usr/lib/jvm/java-17-openjdk-amd64',
    jvm_type               => 'openjdk-17',
    db                     => 'mysql',
    dbport                 => '3306',
    dbdriver               => 'com.mysql.jdbc.Driver',
    dbtype                 => 'mysql8',
    mysql_connector_manage => true,
    dburl                  => $dburl,
    dbuser                 => $database_user,
    dbpassword             => $database_password,
    dbname                 => $database_name,
    dbserver               => $database_host,
    jvm_xms                => $initial_heap_size,
    jvm_xmx                => $maximum_heap_size,
    java_opts              => $java_opts,
    service_manage         => true,
    service_ensure         => $service_status,
    service_enable         => $service_status ? {
                                'running' => true,
                                'stopped' => false
                              },
    proxy                  => {
                                proxyName  => $servername,
                                proxyPort  => '443',
                                scheme     => 'https'
                              }
  }

  # include ::profiles::atlassian::jira::monitoring
  # include ::profiles::atlassian::jira::metrics
  # include ::profiles::atlassian::jira::backup
  # include ::profiles::atlassian::jira::logging
}
