define profiles::mysql::app_user (
  String                    $user,
  String                    $database,
  String                    $password,
  Enum['present', 'absent'] $ensure   = 'present',
  String                    $table    = '*',
  Boolean                   $readonly = false,
  Boolean                   $remote   = false
) {

  include ::profiles

  $allowed_hosts = $remote ? { true => '%', false => '127.0.0.1' }
  $privileges    = $readonly ? { true => ['READ', 'SHOW VIEW'], false => ['ALL'] }

  mysql_user { "${user}@${allowed_hosts}":
    ensure        => $ensure,
    password_hash => mysql::password($password),
  }

  mysql_grant { "${user}@${allowed_hosts}/${database}.${table}":
    ensure        => $ensure,
    user          => "${user}@${allowed_hosts}",
    options       => ['GRANT'],
    privileges    => $privileges,
    table         => "${database}.${table}"
  }
}
