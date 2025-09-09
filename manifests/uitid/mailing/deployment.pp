class profiles::uitid::mailing::deployment (

  String           $version    = 'latest',
  String           $repository = 'uitid-mailing',
  String           $config_source,
  Integer          $portbase   = 4800,
  Boolean          $cron_enabled,
  String $mailing_render_cron_schedule,
  String $mailing_status_cron_schedule,
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
    ensure        => 'present',
    user          => 'glassfish',
    passwordfile  => '/home/glassfish/asadmin.pass',
    contextroot   => 'mailing',
    precompilejsp => false,
    source        => '/opt/cultuurnet-mailing-app/cultuurnet-mailing-app.war',
    require       => [User['glassfish']],
  }
  $cron_expr_render = split($mailing_render_cron_schedule, ' ')

  cron { 'mailing_render':
    ensure     => $cron_enabled ? {
      true  => 'present',
      false => 'absent'
    },    user => 'www-data',
    minute     => split($cron_expr_render[0], ','),
    hour       => split($cron_expr_render[1], ','),
    monthday   => split($cron_expr_render[2], ','),
    month      => split($cron_expr_render[3], ','),
    weekday    => split($cron_expr_render[4], ','),
    command    => "/usr/bin/curl http://127.0.0.1:${glassfish_domain_http_port}/mailing/rest/mailing/render",
  }
  $cron_expr_status = split($mailing_status_cron_schedule, ' ')

  cron { 'mailing_refreshstatus':
    ensure   => $cron_enabled ? {
      true  => 'present',
      false => 'absent'
    },
    user     => 'www-data',
    minute   => split($cron_expr_status[0], ','),
    hour     => split($cron_expr_status[1], ','),
    monthday => split($cron_expr_status[2], ','),
    month    => split($cron_expr_status[3], ','),
    weekday  => split($cron_expr_status[4], ','),
    command  => "/usr/bin/curl http://127.0.0.1:${glassfish_domain_http_port}/mailing/rest/mailing/refreshstatus",
  }
}
