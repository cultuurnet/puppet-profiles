class profiles::mysql::root_my_cnf (
  String           $root_user     = 'root',
  Optional[String] $root_password = undef,
  String           $host          = 'localhost'

) inherits ::profiles {

  file { 'root_my_cnf':
    ensure  => 'file',
    path    => '/root/.my.cnf',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('profiles/mysql/my.cnf.erb'),
  }
}
