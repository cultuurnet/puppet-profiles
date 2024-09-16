class profiles::atlassian::jira (
  String                     $version,
  Enum['running', 'stopped'] $service_status         = 'running',
  Boolean                    $lvm                    = false,
  Optional[String]           $volume_group           = undef,
  Optional[String]           $installdir_volume_size = undef,
  String                     $homedir_volume_size    = undef,
  String                     $servername,
  Array                      $serveraliases          = [],
  String                     $dbpassword,
  String                     $dbserver,
  String                     $jvm_xms                = '4100m',
  String                     $jvm_xmx                = '4100m',
  String                     $jvm_permgen            = '768m',
  String                     $java_opts
) inherits ::profiles {

  $dbuser       = 'jirauser'
  $dbname       = 'jiradb'
  $dburl_params = 'useUnicode=true&amp;characterEncoding=UTF8&amp;sessionVariables=default_storage_engine=InnoDB'
  $dburl        = "jdbc:mysql://${dbserver}:3306/${$dbname}?${dburl_params}"

  include ::profiles::java
  include ::profiles::apache

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    destination => "http://127.0.0.1:${tomcat_port}",
    aliases     => $serveraliases
  }

  realize Group['jira']
  realize User['jira']

  # setup storage
  if $lvm {
    unless ($volume_group and $installdir_volume_size and $homedir_volume_size) {
      fail("with LVM enabled, expects a value for 'volume_group', 'installdir_volume_size' and 'homedir_volume_size'")
    }

    profiles::lvm::mount { 'jira_installdir':
      volume_group => $volume_group,
      size         => $installdir_volume_size,
      mountpoint   => '/opt/jira',
      fs_type      => 'ext4',
      owner        => 'jira',
      group        => 'jira',
      require      => [Group['jira'], User['jira']]
    }
    profiles::lvm::mount { 'jira_homedir':
      volume_group => $volume_group,
      size         => $homedir_volume_size,
      mountpoint   => '/home/jira',
      fs_type      => 'ext4',
      owner        => 'jira',
      group        => 'jira',
      require      => [Group['jira'], User['jira']]
    }
  } else {
    file { $installdir:
      ensure  => 'directory',
      owner   => 'jira',
      group   => 'jira',
      require => [Group['jira'], User['jira']]
    }
    file { $homedir:
      ensure  => 'directory',
      owner   => 'jira',
      group   => 'jira',
      require => [Group['jira'], User['jira']]
    }
  }

  # configure database
  if $dbserver == '127.0.0.1' {
    include ::profiles::mysql::server

    $database_host_remote    = false
    $database_host_available = true

    Class['profiles::mysql::server'] -> Mysql_database[$dbname]
  } else {
    include ::profiles::mysql::rds

    $database_host_remote = true

    if $facts['mysqld_version'] {
      $database_host_available = true

      Class['profiles::mysql::rds'] -> Mysql_database[$dbname]
    } else {
      $database_host_available = false
    }
  }

  if $database_host_available {
    mysql_database { $dbname:
      charset => 'utf8mb4',
      collate => 'utf8mb4_unicode_ci'
    }

    profiles::mysql::app_user { "${dbuser}@${dbname}":
      password => $dbpassword,
      remote   => $database_host_remote,
      require  => Mysql_database[$dbname]
    }
  }

  # insall jira
  class { 'jira':
    version                => $version,
    installdir             => '/opt/jira',
    homedir                => '/home/jira',
    tomcat_port            => 8080,
    manage_user            => false,
    javahome               => '/usr/lib/jvm/java-11-openjdk-amd64',
    jvm_type               => 'openjdk-11',
    db                     => 'mysql',
    dbport                 => '3306',
    dbdriver               => 'com.mysql.jdbc.Driver',
    dbtype                 => 'mysql8',
    mysql_connector_manage => true,
    dburl                  => $dburl,
    dbuser                 => $dbuser,
    dbpassword             => $dbpassword,
    dbname                 => $dbname,
    dbserver               => $dbserver,
    jvm_xms                => $jvm_xms,
    jvm_xmx                => $jvm_xmx,
    jvm_permgen            => $jvm_permgen,
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
