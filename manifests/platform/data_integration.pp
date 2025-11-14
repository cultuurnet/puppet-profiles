class profiles::platform::data_integration (
  String  $database_name,
  Boolean $dump_empty_tables = true,
  Integer $cron_hour         = 2,
  String  $timezone          = 'UTC'

) inherits profiles {

  $database_user          = 'sling'
  $database_password_seed = $facts['ec2_metadata'] ? {
                              undef   => "${database_name}_sling_password",
                              default => join(["${database_name}_sling_password", file($settings::hostprivkey)], "\n")
                            }
  $database_password      = fqdn_rand_string(20, $database_password_seed)

  include profiles::data_integration

  profiles::mysql::app_user { "${database_user}@${database_name}":
    password => $database_password,
    tables   => '*',
    readonly => true,
    remote   => false
  }

  profiles::sling::connection { $database_name:
    type          => 'mysql',
    configuration => {
                        user     => $database_user,
                        password => $database_password,
			host     => '127.0.0.1',
                        database => $database_name
                     },
    require       => Profiles::Mysql::App_user["${database_user}@${database_name}"]
  }

  file { 'parquetdump_to_gcs':
    ensure  => 'file',
    path    => '/usr/local/bin/parquetdump_to_gcs',
    mode    => '0755',
    content => template('profiles/platform/parquetdump_to_gcs.sh.erb'),
    require => [Profiles::Sling::Connection[$database_name], Class['profiles::data_integration']]
  }

  cron { 'parquetdump_to_gcs':
    ensure      => 'present',
    command     => '/usr/local/bin/parquetdump_to_gcs',
    environment => ['SHELL=/bin/bash', "TZ=${timezone}", 'MAILTO=infra+cron@publiq.be'],
    hour        => $cron_hour,
    minute      => 0,
    require     => File['parquetdump_to_gcs']
  }
}
