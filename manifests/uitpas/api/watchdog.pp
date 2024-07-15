class profiles::uitpas::api::watchdog (
  String                        $health_url            = 'https://localhost:4881/uitid/rest/uitpas/health',
  String                        $cardsystem_health_url = 'https://localhost:4881/uitid/rest/cardsystem/login',
  String                        $configfile            = '/etc/default/uitpas-watchdog',
  String                        $logfile               = '/var/log/uitpas-watchdog',
  Integer                       $check_frequency       = 600,
  Variant[String,Array[String]] $slack_webhooks        = undef,
) inherits ::profiles {

  file { 'uitpas watchdog configfile':
    path    => $configfile,
    content => template('profiles/uitpas/api/deployment/uitpas-watchdog-config.erb'),
    ensure  => 'file',
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0600'
  }

  file { 'uitpas watchdog script':
    path    => '/usr/local/bin/uitpas-watchdog.sh'
    content => template('profiles/uitpas/api/deployment/uitpas-watchdog.sh.erb'),
    ensure  => 'file',
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => '0755'
  }

  systemd::unit_file { 'uitpas-watchdog.service':
    content => template('profiles/uitpas/api/deployment/uitpas-watchdog.service.erb'),
    enable  => true,
    active  => true,
    require => [ Service['uitpas'], File['uitpas watchdog script'], File['uitpas watchdog configfile'] ]
  }
}
