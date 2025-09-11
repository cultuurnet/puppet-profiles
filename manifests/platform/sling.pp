class profiles::platform::sling (
  String  $database_name,
  String  $project_id,
  String  $bucket_name,
  Boolean $dump_empty_tables = true,
  Integer $cron_hour         = 2,
  String  $local_timezone    = 'UTC'

) inherits profiles {

  include profiles::sling

  $database_user     = 'sling'
  $database_password = fqdn_rand_string(20, "${database_name}_sling_password")
  $secrets           = lookup('vault:platform/etl')

  realize Apt::Source['publiq-tools']

  profiles::mysql::app_user { "${database_user}@${database_name}":
    password => $app_user_password,
    readonly => true,
    remote   => false
  }

  profiles::sling::connection { $database_name:
    type          => 'mysql',
    configuration => {
                        user     => $database_user,
                        password => $database_password,
                        database => $database_name
                     },
    require       => Profiles::Mysql::App_user["${database_user}@${database_name}"]
  }

  profiles::google::gcloud { 'root':
    credentials => {
      project_id     => $project_id,
      private_key_id => $secrets['gcloud_private_key_id'],
      private_key    => $secrets['gcloud_private_key'],
      client_id      => $secrets['gcloud_client_id'],
      client_email   => $secrets['gcloud_client_email']
    }
  }

  file { '/data/parquetdumps':
    ensure => 'directory'
  }

  file { 'parquetdump_to_gcs':
    ensure  => 'file',
    path    => '/usr/local/bin/parquetdump_to_gcs',
    mode    => '0755',
    content => template('profiles/sling/parquetdump_to_gcs.sh.erb'),
    require => Profiles::Google::Gcloud['root']
  }

  cron { 'parquetdump_to_gcs':
    ensure      => 'present',
    command     => '/usr/local/bin/parquetdump_to_gcs',
    environment => ['SHELL=/bin/bash', "TZ=${local_timezone}", 'MAILTO=infra+cron@publiq.be'],
    hour        => $cron_hour,
    minute      => 0,
    require     => File['parquetdump_to_gcs']
  }
}
