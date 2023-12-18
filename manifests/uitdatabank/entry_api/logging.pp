class profiles::uitdatabank::entry_api::logging inherits ::profiles {

  $basedir = '/var/www/udb3-backend'

  realize Group['www-data']
  realize User['www-data']

  include profiles::logrotate

  logrotate::rule { 'uitdatabank-entry-api':
    path         => "${basedir}/log/*.log",
    rotate       => 10,
    create_owner => 'www-data',
    create_group => 'www-data',
    postrotate   => 'systemctl restart udb3-amqp-listener-uitpas udb3-bulk-label-offer-worker udb3-event-export-workers.target',
    require      => [Group['www-data'], User['www-data']],
    *            => $profiles::logrotate::default_rule_attributes
  }
}
