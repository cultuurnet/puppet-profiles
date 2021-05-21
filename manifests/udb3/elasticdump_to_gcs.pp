class profiles::udb3::elasticdump_to_gcs (
  String  $gcs_bucket_name,
  String  $gcs_key_file_source,
  String  $index_name,
  Integer $batch_size           = 100,
  Boolean $source_only          = false,
  String  $date_specifier       = undef,
  String  $local_timezone       = 'UTC'
) {

  contain ::profiles

  include ::profiles::apt::updates
  include ::profiles::packages
  include ::profiles::elasticdump

  realize Profiles::Apt::Update['cultuurnet-tools']

  realize Package['gcsfuse']

  if $source_only {
    $option_source_only = '-s'
  } else {
    $option_source_only = ''
  }

  if $date_specifier {
    $option_date_specifier = "-d ${date_specifier}"
  }

  $options = join([ $option_source_only, $option_date_specifier], ' ')

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
    require => [ Class['profiles::elasticdump'], Package['gcsfuse'], File['gcs_credentials.json']]
  }

  file { 'midnight_elasticdump_to_gcs':
    path    => '/usr/local/bin/midnight_elasticdump_to_gcs',
    content => "test $(date +%0H) -eq 0 && /usr/local/bin/elasticdump_to_gcs ${options}\n",
    mode    => '0755',
    require => File['elasticdump_to_gcs']
  }

  cron { 'elasticdump_to_gcs':
    command     => '/usr/local/bin/midnight_elasticdump_to_gcs',
    environment => [ 'SHELL=/bin/bash', "TZ=${local_timezone}"],
    user        => 'ubuntu',
    hour        => '*',
    minute      => '00',
    require     => [ File['midnight_elasticdump_to_gcs'], File['/mnt/gcs/cloud-composer']]
  }
}
