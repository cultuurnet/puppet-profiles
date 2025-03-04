class profiles::elasticsearch::backup (
  Boolean          $lvm            = false,
  Optional[String] $volume_group   = undef,
  Optional[String] $volume_size    = undef,
  Integer          $dump_hour      = 0,
  Integer          $retention_days = 7
) inherits ::profiles {

  $mtime = $retention_days - 1

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'elasticsearchbackup':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/backup/elasticsearch',
      fs_type      => 'ext4',
      before       => [File['/data/backup/elasticsearch/current'], File['/data/backup/elasticsearch/archive']]
    }
  } else {

    realize File['/data']
    realize File['/data/backup']

    file { '/data/backup/elasticsearch':
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File['/data/backup'],
      before  => [File['/data/backup/elasticsearch/current'], File['/data/backup/elasticsearch/archive']]
    }
  }

  file { '/data/backup/elasticsearch/current':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755'
  }

  file { '/data/backup/elasticsearch/archive':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755'
  }

  include profiles::elasticdump

  file { '/usr/local/sbin/elasticsearchbackup.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('profiles/elasticsearch/elasticsearchbackup.sh.erb')
  }

  cron { 'elasticsearch-backup':
    command     => "/usr/bin/test $(date +\\%0H) -eq ${dump_hour} && /usr/local/sbin/elasticsearchbackup.sh",
    environment => ['TZ=Europe/Brussels', 'MAILTO=infra+cron@publiq.be'],
    user        => 'root',
    hour        => '*',
    minute      => 0,
    require     => [File['/usr/local/sbin/elasticsearchbackup.sh'], File['/data/backup/elasticsearch/current'], File['/data/backup/elasticsearch/archive']]
  }
}
