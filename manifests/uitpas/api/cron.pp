class profiles::uitpas::api::cron (
  Integer $portbase = 4800
) inherits ::profiles {

  $http_port               = String($portbase + 80)
  $base_url                = "http://127.0.0.1:${http_port}"
  $cron_logdir             = '/var/log/uitpas-cron'
  $cron_default_attributes = {
                               user    => 'glassfish',
                               require => User['glassfish']
                             }

  include profiles::logrotate

  realize Group['glassfish']
  realize User['glassfish']

  file { $cron_logdir:
    ensure  => 'directory',
    owner   => 'glassfish',
    group   => 'glassfish',
    require => [User['glassfish'],Group['glassfish']]
  }

  logrotate::rule { 'uitpas-cronjobs':
    path          => "${cron_logdir}/*.log",
    rotate        => 10,
    require       => File[$cron_logdir],
    *             => $profiles::logrotate::default_rule_attributes
  }

  cron {'uitpas enduser clearcheckincodes':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/enduser/clearcheckincodes' >> ${cron_logdir}/clearcheckincodes.log 2>&1",
    hour    => '3',
    minute  => '5',
    *       => $cron_default_attributes
  }

  cron { 'uitpas milestone batch activity':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/activity' >> ${cron_logdir}/activity.log 2>&1",
    hour    => '1',
    minute  => '2',
    *       => $cron_default_attributes
  }

  cron { 'uitpas milestone batch points':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/points' >> ${cron_logdir}/points.log 2>&1",
    hour    => '2',
    minute  => '2',
    *       => $cron_default_attributes
  }

  cron { 'uitpas milestone batch birthday':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/birthday' >> ${cron_logdir}/birthday.log 2>&1",
    hour    => '4',
    minute  => '2',
    *       => $cron_default_attributes
  }

  cron { 'uitpas passholder indexpointspromotions':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/passholder/indexpointspromotions?unindexedOnly=true' >> ${cron_logdir}/indexpointspromotions.log 2>&1",
    hour    => '*',
    minute  => '34',
    *       => $cron_default_attributes
  }

  cron { 'uitpas autorenew triggerupload':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerupload' >> ${cron_logdir}/triggerupload.log 2>&1",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes
  }

  cron { 'uitpas autorenew triggerdownload':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerdownload' >> ${cron_logdir}/triggerdownload.log 2>&1",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes
  }

  cron { 'uitpas autorenew triggerprocess':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerprocess' >> ${cron_logdir}/triggerprocess.log 2>&1",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes
  }

  cron { 'uitpas trigger price message':
    ensure  => 'absent',
    command => "/usr/bin/curl '${base_url}/uitid/rest/bootstrap/uitpas/trigger-event-price-messages?max=100' >> ${cron_logdir}/trigger-event-price-message.log 2>&1",
    hour    => '*',
    minute  => '*',
    *       => $cron_default_attributes
  }

  cron { 'uitpas balie indexbalies':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/balie/indexbalies' >> ${cron_logdir}/indexbalies.log 2>&1",
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
