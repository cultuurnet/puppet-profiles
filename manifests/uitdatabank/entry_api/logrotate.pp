class profiles::uitdatabank::entry_api::logrotate (
  String $basedir = '/var/www/udb3-backend'
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  include profiles::logrotate

  logrotate::rule { 'uitdatabank-entry-api':
    path         => "${basedir}/log/*.log",
    rotate       => 10,
    create_owner => 'www-data',
    create_group => 'www-data',
    postrotate   => 'systemctl restart uitdatabank-*',
    require      => [Group['www-data'], User['www-data']],
    *            => $profiles::logrotate::default_rule_attributes
  }
}
