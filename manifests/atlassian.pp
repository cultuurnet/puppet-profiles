class profiles::atlassian (
  String  $database_host      = '127.0.0.1',
  Boolean $install_jira       = true,
  Boolean $install_confluence = true
) inherits ::profiles {

  realize Apt::Source['publiq-tools']
  realize Package['mysql-connector-j']

  if $database_host == '127.0.0.1' {
    $database_host_remote    = false
    $database_host_available = true

    include profiles::mysql::server
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
    if $install_jira {
      class { 'profiles::atlassian::jira':
        database_host => $database_host
      }
    }

    if $install_confluence {
      class { 'profiles::atlassian::confluence':
        database_host => $database_host
      }
    }
  }
}
