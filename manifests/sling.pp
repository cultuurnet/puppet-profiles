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
  # Ensure the sling /root/.sling directory exists
  file { '/root/.sling':
    ensure => 'directory',
  }
  file { '/root/parquetdumps':
    ensure => 'directory',
  }

  file { '/root/.sling/env.yaml':
    ensure  => 'file',
    content => template('profiles/sling/sling.env.erb'),
  }

  file { '/root/.sling/parquet_dump.sh':
    ensure  => 'file',
    mode    => '0755',
    content => template('profiles/sling/parquet_dump.sh.erb'),
  }
  cron { 'sling_parquet_dump':
    ensure  => 'present',
    command => '/root/.sling/parquet_dump.sh',
    description => 'Sling parquet dump',
    hour    => 3,
    minute  => 0,
    require => File['/root/.sling/parquet_dump.sh'],
  }

}
