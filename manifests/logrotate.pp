class profiles::logrotate inherits ::profiles {

  class { '::logrotate':
    ensure => 'installed',
    config => {
                compress      => true,
                delaycompress => true,
                rotate        => 10,
                rotate_every  => 'week',
                missingok     => true,
                ifempty       => true
              }
  }
}
