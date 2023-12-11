class profiles::apache::logging inherits ::profiles {

  include profiles::logrotate

  logrotate::rule { 'apache2':
    path          => '/var/log/apache2/*.log',
    rotate        => 30,
    rotate_every  => 'day',
    create        => true,
    create_mode   => '0640',
    create_owner  => 'root',
    create_group  => 'adm',
    compress      => true,
    delaycompress => true,
    sharedscripts => true,
    postrotate    => 'systemctl status apache2 > /dev/null 2>&1 && systemctl reload apache2 > /dev/null 2>&1'
  }
}
