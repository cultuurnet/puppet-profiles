class profiles::mysql::remote_server (
  String $host
) inherits ::profiles {

  File <<| tag == 'mysqld_version' and tag == $host |>>
  Profiles::Mysql::My_cnf <<| title == 'root' and host == $host |>>
}
