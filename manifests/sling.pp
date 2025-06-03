class profiles::sling (
  String $version                 = 'latest',
  Optional[String] $database_name = undef,
) inherits profiles {
  realize Apt::Source['publiq-tools']

  # Generate a random password if deploying
  if $database_name {
    $app_user_password = fqdn_rand_string(20, "${database_name}_sling_password")
  }

  package { 'sling':
    ensure  => $version,
    require => Apt::Source['publiq-tools'],
  }

  profiles::mysql::app_user { "sling@${database_name}":
    password => $app_user_password,
    readonly => true,
    remote   => false,
    require  => Mysql_database[$database_name],
  }
}
