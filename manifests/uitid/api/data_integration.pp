class profiles::uitid::api::data_integration (
  String $database_name,
  String $database_host = '127.0.0.1',
) inherits ::profiles {

  $database_password_seed = $facts['ec2_metadata'] ? {
                              undef   => "${database_name}_sling_password",
                              default => join(["${database_name}_sling_password", file($settings::hostprivkey)], "\n")
                            }
  $database_password      = fqdn_rand_string(20, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', $database_password_seed)

  include profiles::data_integration

  profiles::mysql::app_user { "sling@${database_name}":
    tables   => ['EVENTS_DBLOG'],
    password => $database_password,
    readonly => true,
    remote   => $database_host ? {
                  '127.0.0.1' => false,
                  default     => true
                }
  }

  profiles::sling::connection { $database_name:
    type          => 'mysql',
    configuration => {
                        user     => 'sling',
                        password => $database_password,
                        host     => $database_host,
                        database => $database_name
                     },
    require       => Profiles::Mysql::App_user["sling@${database_name}"]
  }

  file { 'parquetdump_to_gcs':
    ensure  => 'file',
    path    => '/usr/local/bin/parquetdump_to_gcs',
    mode    => '0755',
    content => template('profiles/uitid/api/parquetdump_to_gcs.sh.erb'),
    require => [Class['profiles::data_integration'], Profiles::Sling::Connection[$database_name]]
  }

  cron { 'parquetdump_to_gcs':
    ensure      => 'present',
    command     => '/usr/local/bin/parquetdump_to_gcs',
    environment => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be'],
    hour        => 0,
    minute      => 15,
    require     => File['parquetdump_to_gcs']
  }
}
