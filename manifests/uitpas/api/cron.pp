class profiles::uitpas::api::cron (
  Integer $portbase = 4800,
  Boolean $cron_enabled = true,
  String  $local_timezone = 'Europe/Brussels'
) inherits profiles {
  $http_port               = String($portbase + 80)
  $base_url                = "http://127.0.0.1:${http_port}"
  $cron_logdir             = '/var/log/uitpas-cron'

  $cron_default_attributes = {
    user    => 'glassfish',
    require => User['glassfish'],
    environment => ['SHELL=/bin/bash', "TZ=${local_timezone}", 'MAILTO=infra+cron@publiq.be']
  }

  include profiles::logrotate

  realize Group['glassfish']
  realize User['glassfish']

  file { $cron_logdir:
    ensure  => 'directory',
    owner   => 'glassfish',
    group   => 'glassfish',
    require => [User['glassfish'],Group['glassfish']],
  }

  logrotate::rule { 'uitpas-cronjobs':
    path    => "${cron_logdir}/*.log",
    rotate  => 10,
    require => File[$cron_logdir],
    *       => $profiles::logrotate::default_rule_attributes,
  }

  cron { 'uitpas enduser clearcheckincodes':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 3 && /usr/bin/curl '${base_url}/uitid/rest/uitpas/enduser/clearcheckincodes' >> ${cron_logdir}/clearcheckincodes.log 2>&1",
    hour    => '*',
    minute  => '5',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas milestone batch activity':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 1 && /usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/activity' >> ${cron_logdir}/activity.log 2>&1",
    hour    => '*',
    minute  => '2',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas milestone batch points':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 2 && /usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/points' >> ${cron_logdir}/points.log 2>&1",
    hour    => '*',
    minute  => '2',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas milestone batch birthday':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 4 && /usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/birthday' >> ${cron_logdir}/birthday.log 2>&1",
    hour    => '*',
    minute  => '2',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas passholder indexpointspromotions':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/passholder/indexpointspromotions?unindexedOnly=true' >> ${cron_logdir}/indexpointspromotions.log 2>&1",
    hour    => '*',
    minute  => '34',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas autorenew triggerupload':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerupload' >> ${cron_logdir}/triggerupload.log 2>&1",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas autorenew triggerdownload':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerdownload' >> ${cron_logdir}/triggerdownload.log 2>&1",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas autorenew triggerprocess':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerprocess' >> ${cron_logdir}/triggerprocess.log 2>&1",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas trigger price message':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/curl '${base_url}/uitid/rest/bootstrap/uitpas/trigger-event-price-messages?max=100' >> ${cron_logdir}/trigger-event-price-message.log 2>&1",
    hour    => '*',
    minute  => '*',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas balie indexbalies':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 5 && /usr/bin/curl '${base_url}/uitid/rest/uitpas/balie/indexbalies' >> ${cron_logdir}/indexbalies.log 2>&1",
    hour    => '*',
    minute  => '14',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas clear jpa cache':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/curl -q -s '${base_url}/uitid/rest/bootstrap/uitpas/clearJpaCache' > /dev/null",
    hour    => '*/6',
    minute  => '30',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas clear cache':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 6 && /usr/bin/curl -q -s '${base_url}/uitid/rest/bootstrap/uitpas/clearcaches' > /dev/null",
    hour    => '*',
    minute  => '15',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas balie financial reminderemail':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 8 && /usr/bin/curl '${base_url}/uitid/rest/cron/balie/financial-reminderemail' >> ${cron_logdir}/balie-financial-reminderemail.log 2>&1",
    hour    => '*',
    minute  => '0',
    monthday => '1',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas balie financial export cleanup':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 1 && /usr/bin/curl '${base_url}/uitid/rest/cron/balie/financial-export-cleanup' >> ${cron_logdir}/balie-financial-export-cleanup.log 2>&1",
    hour    => '*',
    minute  => '14',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas balie checkcardstockunderlimit':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 0 && /usr/bin/curl '${base_url}/uitid/rest/cron/balie/checkcardstockunderlimit' >> ${cron_logdir}/balie-checkcardstockunderlimit.log 2>&1",
    hour    => '*',
    minute  => '15',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas orders trigger order completion':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/curl '${base_url}/uitid/rest/cron/orders/trigger-order-completion' >> ${cron_logdir}/orders-trigger-order-completion.log 2>&1",
    hour    => '*',
    minute  => '*/5',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas orders check incomplete orders':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 9 && /usr/bin/curl '${base_url}/uitid/rest/cron/orders/check-incomplete-orders' >> ${cron_logdir}/orders-check-incomplete-orders.log 2>&1",
    hour    => '*',
    minute  => '0',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas passholder kansenstatuutalmostexpired':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 0 && /usr/bin/curl '${base_url}/uitid/rest/cron/passholder/kansenstatuutalmostexpired' >> ${cron_logdir}/passholder-kansenstatuutalmostexpired.log 2>&1",
    hour    => '*',
    minute  => '45',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas passholder norecentcheckinreminder':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 0 && /usr/bin/curl '${base_url}/uitid/rest/cron/passholder/norecentcheckinreminder' >> ${cron_logdir}/passholder-norecentcheckinreminder.log 2>&1",
    hour    => '*',
    minute  => '25',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas passholder welcomemailreminder':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 0 && /usr/bin/curl '${base_url}/uitid/rest/cron/passholder/welcomemailreminder' >> ${cron_logdir}/passholder-welcomemailreminder.log 2>&1",
    hour    => '*',
    minute  => '10',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas periodic cardsystemmembership cleaning':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 3 && /usr/bin/curl '${base_url}/uitid/rest/cron/periodic-cardsystemmembership-cleaning' >> ${cron_logdir}/periodic-cardsystemmembership-cleaning.log 2>&1",
    hour    => '*',
    minute  => '38',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas external ticketsales sync':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 4 && /usr/bin/curl '${base_url}/uitid/rest/cron/external-ticketsales/sync' >> ${cron_logdir}/external-ticketsales-sync.log 2>&1",
    hour    => '*',
    minute  => '45',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas external ticketsales resolve':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 5 && /usr/bin/curl '${base_url}/uitid/rest/cron/external-ticketsales/resolve' >> ${cron_logdir}/external-ticketsales-resolve.log 2>&1",
    hour    => '*',
    minute  => '1',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas external ticketsales process':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 5 && /usr/bin/curl '${base_url}/uitid/rest/cron/external-ticketsales/process' >> ${cron_logdir}/external-ticketsales-process.log 2>&1",
    hour    => '*',
    minute  => '45',
    *       => $cron_default_attributes,
  }

  cron { 'uitpas external ticketsales alert':
    ensure  => $cron_enabled ? { true => 'present', default => 'absent' },
    command => "/usr/bin/test \$(date +\\%H) -eq 6 && /usr/bin/curl '${base_url}/uitid/rest/cron/external-ticketsales/alert' >> ${cron_logdir}/external-ticketsales-alert.log 2>&1",
    hour    => '*',
    minute  => '45',
    *       => $cron_default_attributes,
  }
}
