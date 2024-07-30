class profiles::uitdatabank::search_api::listeners (
  $basedir = '/var/www/udb3-search-service'
) inherits ::profiles {

  include profiles::logrotate

  realize Group['www-data']
  realize User['www-data']

  profiles::uitdatabank::search_api::listener { 'uitdatabank-consume-api':
    command => 'consume-udb3-api',
    basedir => $basedir,
    before  => Logrotate::Rule['search_api-listeners']
  }

  profiles::uitdatabank::search_api::listener { 'uitdatabank-consume-cli':
    command   => 'consume-udb3-cli',
    basedir   => $basedir,
    before  => Logrotate::Rule['search_api-listeners']
  }

  profiles::uitdatabank::search_api::listener { 'uitdatabank-consume-related':
    command   => 'consume-udb3-related',
    basedir   => $basedir,
    before  => Logrotate::Rule['search_api-listeners']
  }

  logrotate::rule { 'search_api-listeners':
    path          => "${basedir}/log/*.log",
    rotate        => 10,
    create_owner  => 'www-data',
    create_group  => 'www-data',
    postrotate    => '/usr/bin/systemctl restart uitdatabank-consume-*',
    require       => [Group['www-data'], User['www-data']],
    *             => $profiles::logrotate::default_rule_attributes
  }
}
