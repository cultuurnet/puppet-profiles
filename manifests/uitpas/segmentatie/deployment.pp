class profiles::uitpas::segmentatie::deployment (
  String           $config_source,
  String           $version       = 'latest',
  String           $repository    = 'uitpas-segmentatie',
  Integer          $portbase      = 4800,
  Boolean          $cron_enabled  = true
) inherits profiles {
  $glassfish_domain_http_port = $portbase + 80
  $database_name              = 'uitpas_segmentatie'
  $database_user              = 'uitpas_segmentatie'

  realize Apt::Source[$repository]
  realize Group['glassfish']
  realize User['glassfish']

  package { 'uitpas-segmentatie':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => App['uitpas-segmentatie']
  }

  cron { 'uitpas-segmentatie-sync':
    ensure    => $cron_enabled ? {
      true  => 'present',
      false => 'absent'
    },
    command  => "/usr/bin/curl -X POST 'http://127.0.0.1:${glassfish_domain_http_port}/segmentation/rest/sync'",
    user    => 'www-data',
    hour    => 1,
    minute  => 45,
    require => [Group['glassfish'], User['glassfish'], Package['uitpas-segmentatie']],
  }

  app { 'uitpas-segmentatie':
    ensure        => 'present',
    portbase      => String($portbase),
    user          => 'glassfish',
    passwordfile  => '/home/glassfish/asadmin.pass',
    contextroot   => 'segmentation',
    precompilejsp => false,
    source        => '/opt/uitpas-segmentatie/uitpas-segmentatie.war',
    require       => [Group['glassfish'], User['glassfish']],
  }
}
