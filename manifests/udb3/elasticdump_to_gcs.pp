class profiles::udb3::elasticdump_to_gcs (
  String      $gcs_bucket_name,
  String      $gcs_key_file_source,
  String      $index_name,
  String      $local_timezone = 'UTC',
  Integer[-1] $size           = '-1'
) {

  contain ::profiles

  include ::profiles::repositories
  include ::profiles::packages

  realize Apt::Source['nodejs_10.x']
  realize Apt::Source['tools']
  realize Profiles::Apt::Update['nodejs_10.x']
  realize Profiles::Apt::Update['tools']

  realize Package['elasticdump']
  realize Package['gcsfuse']

  file { '/mnt/gcs':
    ensure => 'directory'
  }

  file { '/mnt/gcs/cloud-composer':
    ensure => 'directory'
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
    require => [ Package['elasticdump'], Package['gcsfuse'], File['gcs_credentials.json']],
  }

  cron { 'elasticdump_to_gcs':
    command => '/usr/local/bin/elasticdump_to_gcs',
    require => [ File['elasticdump_to_gcs'], File['/mnt/gcs/cloud-composer']],
    user    => 'ubuntu',
    hour    => '*',
    minute  => '59'
  }
}
