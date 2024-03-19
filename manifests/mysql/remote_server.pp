class profiles::mysql::remote_server (
  String $host
) inherits ::profiles {

  realize Package['mysql-client']

  File <<| tag == 'mysqld_version' and tag == $host |>>
  Profiles::Mysql::Root_my_cnf <<| title == $host |>>
}
