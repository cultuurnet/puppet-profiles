class profiles::uitpas::api::cron (
  Integer $portbase = 4800
) inherits ::profiles {

  $http_port               = String($portbase + 80)
  $base_url                = "http://127.0.0.1:${http_port}"
  $cron_default_attributes = {
                               user        => 'glassfish',
                               require     => User['glassfish']
                             }

  include profiles::logrotate

  realize Group['glassfish']
  realize User['glassfish']

  file { '/var/log/uitpas-cron':
    ensure  => 'directory',
    owner   => 'glassfish',
    group   => 'glassfish',
    require => [User['glassfish'],Group['glassfish']]
  }

  logrotate::rule { 'uitpas-cronjobs':
    path          => "/var/log/uitpas-cron/*.log",
    rotate        => 10,
    require       => File['/var/log/uitpas-cron'],
    *             => $profiles::logrotate::default_rule_attributes
  }

  cron {'uitpas enduser clearcheckincodes':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/enduser/clearcheckincodes' >> /var/log/uitpas-cron/clearcheckincodes.log 2>&1",
    hour    => '3',
    minute  => '5',
    *       => $cron_default_attributes
  }

  cron { 'uitpas milestone batch activity':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/activity' >> /var/log/uitpas-cron/activity.log 2>&1",
    hour    => '1',
    minute  => '2',
    *       => $cron_default_attributes
  }

  cron { 'uitpas milestone batch points':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/points' >> /var/log/uitpas-cron/points.log 2>&1",
    hour    => '2',
    minute  => '2',
    *       => $cron_default_attributes
  }

  cron { 'uitpas milestone batch birthday':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/birthday' >> /var/log/uitpas-cron/birthday.log 2>&1",
    hour    => '4',
    minute  => '2',
    *       => $cron_default_attributes
  }

  cron { 'uitpas passholder indexpointspromotions':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/passholder/indexpointspromotions?unindexedOnly=true' >> /var/log/uitpas-cron/indexpointspromotions.log 2>&1",
    hour    => '*',
    minute  => '34',
    *       => $cron_default_attributes
  }

  cron { 'uitpas autorenew triggerupload':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerupload' >> /var/log/uitpas-cron/triggerupload.log 2>&1",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes
  }

  cron { 'uitpas autorenew triggerdownload':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerdownload' >> /var/log/uitpas-cron/triggerdownload.log 2>&1",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes
  }

  cron { 'uitpas autorenew triggerprocess':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerprocess' >> /var/log/uitpas-cron/triggerprocess.log 2>&1",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes
  }

  cron { 'uitpas trigger price message':
    ensure  => 'absent',
    command => "/usr/bin/curl '${base_url}/uitid/rest/bootstrap/uitpas/trigger-event-price-messages?max=100' >> /var/log/uitpas-cron/trigger-event-price-message.log 2>&1",
    hour    => '*',
    minute  => '*',
    *       => $cron_default_attributes
  }

  cron { 'uitpas balie indexbalies':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/balie/indexbalies' >> /var/log/uitpas-cron/indexbalies.log 2>&1",
    hour    => '5',
    minute  => '14',
    *       => $cron_default_attributes
  }

  cron { 'uitpas clear jpa cache':
    command => "/usr/bin/curl -q -s '${base_url}/uitid/rest/bootstrap/uitpas/clearJpaCache' > /dev/null",
    hour    => '*/6',
    minute  => '30',
    *       => $cron_default_attributes
  }

  cron { 'uitpas clear cache':
    command => "/usr/bin/curl -q -s '${base_url}/uitid/rest/bootstrap/uitpas/clearcaches' > /dev/null",
    hour    => '6',
    minute  => '15',
    *       => $cron_default_attributes
  }
}
