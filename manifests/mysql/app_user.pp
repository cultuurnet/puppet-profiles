define profiles::mysql::app_user (
  String                         $password,
  String                         $user     = $title.split('@')[0],
  String                         $database = $title.split('@')[1],
  Enum['present', 'absent']      $ensure   = 'present',
  Variant[String, Array[String]] $tables   = '*',
  Boolean                        $readonly = false,
  Boolean                        $remote   = false
) {

  include ::profiles

  $allowed_hosts = $remote ? { true => '%', false => '127.0.0.1' }
  $privileges    = $readonly ? { true => ['SELECT', 'SHOW VIEW'], false => ['ALL'] }

  ensure_resource('mysql_user', "${user}@${allowed_hosts}", {'ensure' => $ensure, password_hash => mysql::password($password) })

  [$tables].flatten.each |$table| {
    mysql_grant { "${user}@${allowed_hosts}/${database}.${table}":
      ensure     => $ensure,
      user       => "${user}@${allowed_hosts}",
      options    => ['GRANT'],
      privileges => $privileges,
      table      => "${database}.${table}",
      require    => Mysql_user["${user}@${allowed_hosts}"]
    }
  }
}
