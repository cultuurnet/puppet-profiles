class profiles::mysql::remote_server (
  String $host
) inherits ::profiles {

  realize Package['mysql-client']

  class { 'profiles::mysql::remote_instance':
    host => $host
  }

  class { 'profiles::mysql::rds':
    host => $host
  }
}
