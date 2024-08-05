class profiles::uitdatabank::search_api::elasticdump_to_gcs (
  Optional[String] $gcs_bucket_name        = undef,
  Optional[String] $gcs_credentials_source = undef,
  Boolean          $schedule               = false,
  String           $bucket_mountpoint      = '/mnt/gcs',
  String           $bucket_dumplocation    = '',
  Integer          $dump_hour              = 0,
  String           $local_timezone         = 'UTC'
) inherits ::profiles {

  if $gcs_bucket_name {
    unless $bucket_mountpoint =~ /^\/mnt\// {
      fail("Class Profiles::Uitdatabank::Elasticdump_to_gcs expects parameter 'bucket_mountpoint' to start with /mnt")
    }

    class { 'profiles::gcsfuse':
      credentials_source => $gcs_credentials_source
    }

    # We need to create all intermediate directories from /mnt to $bucket_mountpoint, this will provide a list
    $directory_tree = $bucket_mountpoint.split('/').map |$index, $dir| { $bucket_mountpoint.split('/')[0, $index + 1].join('/') }.filter |$item| { ! $item.empty } - ['/mnt']

    file { $directory_tree:
      ensure => 'directory'
    }

    file { 'elasticdump_to_gcs':
      ensure  => 'file',
      path    => '/usr/local/bin/elasticdump_to_gcs',
      content => template('profiles/uitdatabank/search_api/elasticdump_to_gcs.erb'),
      mode    => '0755',
      require => Class['profiles::gcsfuse']
    }

    cron { 'elasticdump_to_gcs':
      ensure      => $schedule ? {
                       true  => 'present',
                       false => 'absent'
                     },
      command     => "/usr/bin/test $(date +\\%0H) -eq ${dump_hour} && /usr/local/bin/elasticdump_to_gcs /data/backup/elasticsearch/current/udb3_core_v*",
      environment => ['SHELL=/bin/bash', "TZ=${local_timezone}", 'MAILTO=infra+cron@publiq.be'],
      hour        => '*',
      minute      => '00',
      require     => [File['elasticdump_to_gcs'], File[$bucket_mountpoint]]
    }
  }
}
