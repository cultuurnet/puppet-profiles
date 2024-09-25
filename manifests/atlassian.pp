class profiles::atlassian (
  String  $database_host      = '127.0.0.1',
  Boolean $install_jira       = true,
  Boolean $install_confluence = true
) inherits ::profiles {

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

  if $install_jira and $database_host_available {
    class { 'profiles::atlassian::jira':
      database_host        => $database_host,
      database_host_remote => $database_host_remote
    }
  }

  if $install_confluence and $database_host_available {
    class { 'profiles::atlassian::confluence':
      database_host        => $database_host,
      database_host_remote => $database_host_remote
    }
  }
}

