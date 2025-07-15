class profiles::projectaanvraag::api::logrotate (
  String $basedir = '/var/www/projectaanvraag-api'
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  include profiles::logrotate

  logrotate::rule { 'projectaanvraag-api':
    path         => "${basedir}/log/*/*.log",
    rotate       => 10,
    create_owner => 'www-data',
    create_group => 'www-data',
    postrotate   => 'systemctl restart projectaanvraag-api',
    require      => [Group['www-data'], User['www-data']],
    *            => $profiles::logrotate::default_rule_attributes
  }
}
