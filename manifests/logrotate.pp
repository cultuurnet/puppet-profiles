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

  $default_rule_attributes = {
                               rotate_every  => 'day',
                               missingok     => true,
                               create        => true,
                               copytruncate  => false,
                               ifempty       => true,
                               create_mode   => '0640',
                               compress      => true,
                               delaycompress => true,
                               sharedscripts => true
                             }
}
