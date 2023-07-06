class profiles::logrotate inherits ::profiles {

  logrotate::conf { '/etc/logrotate.conf':
    compress      => true,
    delaycompress => true,
    rotate        => 10,
    rotate_every  => 'week',
    missingok     => true,
    ifempty       => true,
    su            => true,
    su_user       => 'root',
    su_group      => 'adm'
  }
}
