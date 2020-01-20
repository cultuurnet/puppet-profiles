class profiles::udb3::elasticdump_to_gcs (
  String  $gcs_bucket_name,
  String  $gcs_key_file_source,
  String  $index_name,
  Integer $batch_size = 100,
  String  $local_timezone = 'UTC'
) {

  contain ::profiles

  include ::profiles::repositories
  include ::profiles::packages

  realize Apt::Source['nodejs_10.x']
  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['nodejs_10.x']
  realize Profiles::Apt::Update['cultuurnet-tools']

  realize Package['elasticdump']
  realize Package['gcsfuse']

  file { '/mnt/gcs':
    ensure => 'directory'
  }

  file { '/mnt/gcs/cloud-composer':
    ensure => 'directory',
    owner  => 'ubuntu',
    group  => 'ubuntu'
  }

  file { 'gcs_credentials.json':
    path   => '/etc/gcs_credentials.json',
    mode   => '0644',
    source => $gcs_key_file_source
  }

  file { 'elasticdump_to_gcs':
    path    => '/usr/local/bin/elasticdump_to_gcs',
    content => template('profiles/udb3/elasticdump_to_gcs.erb'),
    mode    => '0755',
    require => [ Package['elasticdump'], Package['gcsfuse'], File['gcs_credentials.json']]
  }

  file { 'midnight_elasticdump_to_gcs':
    path    => '/usr/local/bin/midnight_elasticdump_to_gcs',
    content => "test $(date +%_H) -eq 23 && (sleep 60; /usr/local/bin/elasticdump_to_gcs)\n",
    mode    => '0755',
    require => File['elasticdump_to_gcs']
  }

  cron { 'elasticdump_to_gcs':
    command     => '/usr/local/bin/midnight_elasticdump_to_gcs',
    environment => [ 'SHELL=/bin/bash', "TZ=${local_timezone}"],
    user        => 'ubuntu',
    hour        => '*',
    minute      => '59',
    require     => [ File['midnight_elasticdump_to_gcs'], File['/mnt/gcs/cloud-composer']]
  }
}
