class profiles::uitid::mailing::deployment (

  String           $version           = 'latest',
  String           $repository        = 'uitid-mailing',
  String           $config_source,
  Integer          $portbase          = 4800,
  Boolean          $cron_enabled,
) inherits profiles {
  $database_name = 'uitid_mailing'
  $database_user = 'uitid_mailing'

  $glassfish_domain_http_port = $portbase + 80

  realize Apt::Source[$repository]
  realize User['glassfish']

  package { 'cultuurnet-mailing-app':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => [App['uitid-mailing']],
  }
  app { 'uitid-mailing':
    portbase      => String($portbase),
    user          => 'glassfish',
    passwordfile  => '/home/glassfish/asadmin.pass',
    contextroot   => 'mailing',
    precompilejsp => false,
    source        => '/opt/cultuurnet-mailing-app/cultuurnet-mailing-app.war',
    require       => [User['glassfish']],
  }

  cron { 'mailing_render':
    ensure     => $cron_enabled ? {
      true  => 'present',
      false => 'absent'
    },    user => 'www-data',
    minute      => [5,15,25,35,45,55],
    command     => "/usr/bin/curl http://127.0.0.1:${glassfish_domain_http_port}/mailing/rest/mailing/render",
  }

  cron { 'mailing_refreshstatus':
    ensure     => $cron_enabled ? {
      true  => 'present',
      false => 'absent'
    },    user => 'www-data',
    minute      => '*/2',
    command     => "/usr/bin/curl http://127.0.0.1:${glassfish_domain_http_port}/mailing/rest/mailing/refreshstatus",
  }
}
