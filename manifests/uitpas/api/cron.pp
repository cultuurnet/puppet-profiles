class profiles::uitpas::api::cron (
  Integer $portbase = 4800
) inherits ::profiles {

  $http_port               = String($portbase + 80)
  $base_url                = "http://127.0.0.1:${http_port}"
  $cron_default_attributes = {
                               environment => ['MAILTO=infra+cron@publiq.be'],
                               user        => 'glassfish',
                               require     => User['glassfish']
                             }

  realize Group['glassfish']
  realize User['glassfish']

  cron {'uitpas enduser clearcheckincodes':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/enduser/clearcheckincodes'",
    hour    => '3',
    minute  => '5',
    *       => $cron_default_attributes
  }

  cron { 'uitpas milestone batch activity':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/activity'",
    hour    => '1',
    minute  => '2',
    *       => $cron_default_attributes
  }

  cron { 'uitpas milestone batch points':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/points'",
    hour    => '2',
    minute  => '2',
    *       => $cron_default_attributes
  }

  cron { 'uitpas milestone batch birthday':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/milestone/batch/birthday'",
    hour    => '4',
    minute  => '2',
    *       => $cron_default_attributes
  }

  cron { 'uitpas passholder indexpointspromotions':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/passholder/indexpointspromotions?unindexedOnly=true'",
    hour    => '*',
    minute  => '34',
    *       => $cron_default_attributes
  }

  cron { 'uitpas autorenew triggerupload':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerupload'",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes
  }

  cron { 'uitpas autorenew triggerdownload':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerdownload'",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes
  }

  cron { 'uitpas autorenew triggerprocess':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/autorenew/triggerprocess'",
    hour    => '*',
    minute  => '*/10',
    *       => $cron_default_attributes
  }

  cron { 'uitpas trigger price message':
    command => "/usr/bin/curl '${base_url}/uitid/rest/bootstrap/uitpas/trigger-event-price-messages?max=100'",
    hour    => '*',
    minute  => '*',
    *       => $cron_default_attributes
  }  

  cron { 'uitpas balie indexbalies':
    command => "/usr/bin/curl '${base_url}/uitid/rest/uitpas/balie/indexbalies'",
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
