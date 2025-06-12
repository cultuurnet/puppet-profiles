class profiles::sling (
  String $version                  = 'latest',
  Optional[String] $database_name  = undef,
  Optional[String] $project_id     = undef,
  Optional[String] $bucket_name    = undef,
  Boolean $dump_empty_tables       = true,
  Integer $cron_hour               = 2,
  String           $local_timezone = 'UTC'

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
  }

  if $project_id {
    $secrets = lookup('vault:platform/etl')

    profiles::google::gcloud { 'root':
      credentials => {
        project_id     => $project_id,
        private_key_id => $secrets['gcloud_private_key_id'],
        private_key    => $secrets['gcloud_private_key'],
        client_id      => $secrets['gcloud_client_id'],
        client_email   => $secrets['gcloud_client_email'],
      },
    }
  }
  # Ensure the sling /root/.sling directory exists
  file { '/root/.sling':
    ensure => 'directory',
  }
  file { '/data/parquetdumps':
    ensure => 'directory',
  }

  file { '/root/.sling/env.yaml':
    ensure  => 'file',
    content => template('profiles/sling/sling.env.erb'),
  }

  if $bucket_name {
    file { 'parquetdump_to_gcs':
      ensure  => 'file',
      path    => '/usr/local/bin/parquetdump_to_gcs',
      mode    => '0755',
      content => template('profiles/sling/parquetdump_to_gcs.sh.erb'),
      require => Profiles::Google::Gcloud['root'],
    }
    cron { 'parquetdump_to_gcs':
      ensure  => 'present',
      command => '/usr/local/bin/parquetdump_to_gcs',
      environment => ['SHELL=/bin/bash', "TZ=${local_timezone}", 'MAILTO=infra+cron@publiq.be'],
      hour    => $cron_hour,
      minute  => 0,
      require => File['parquetdump_to_gcs'],
    }
  }
}
