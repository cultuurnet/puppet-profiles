define profiles::mysql::root_my_cnf (
  String           $database_user     = 'root',
  Optional[String] $database_password = undef,
) {

  include ::profiles

  $host = $title

  file { "${host} my.cnf":
    ensure  => 'file',
    path    => '/root/.my.cnf',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('profiles/mysql/my.cnf.erb')
  }
}
