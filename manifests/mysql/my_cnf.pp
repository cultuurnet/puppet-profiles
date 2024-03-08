define profiles::mysql::my_cnf (
  String           $database_user     = 'root',
  Optional[String] $database_password = undef,
  String           $host              = 'localhost'
) {

  include ::profiles

  case $title {
    'root':  {
               $path = '/root/.my.cnf'
             }
    default: {
               $path = "/home/${title}/.my.cnf"

               realize Group[$title]
               realize User[$title]

               Group[$title] -> File["${title} my.cnf"]
               User[$title] -> File["${title} my.cnf"]
             }
  }

  file { "${title} my.cnf":
    ensure  => 'file',
    path    => $path,
    owner   => $title,
    group   => $title,
    mode    => '0400',
    content => template('profiles/mysql/my.cnf.erb')
  }
}
