class profiles::apache::logging (
  Integer $retention_days = 16,
  Logrotate::Size $access_maxsize = '500M'
) inherits ::profiles {

  include profiles::logrotate

  logrotate::rule { 'apache2':
    path         => '/var/log/apache2/*.log',
    rotate       => $retention_days - 1,
    maxsize      => $access_maxsize,
    create_owner => 'root',
    create_group => 'adm',
    postrotate   => 'systemctl status apache2 > /dev/null 2>&1 && systemctl reload apache2 > /dev/null 2>&1',
    *            => $profiles::logrotate::default_rule_attributes
  }
}
