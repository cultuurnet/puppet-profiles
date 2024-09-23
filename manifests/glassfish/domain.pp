define profiles::glassfish::domain (
  Enum['present', 'absent']  $ensure               = 'present',
  Enum['running', 'stopped'] $service_status       = 'running',
  Optional[String]           $initial_heap_size    = undef,
  Optional[String]           $maximum_heap_size    = undef,
  Boolean                    $jmx                  = true,
  Boolean                    $newrelic             = false,
  Optional[String]           $newrelic_license_key = undef,
  String                     $newrelic_app_name    = "${title}-${environment}",
  Integer                    $portbase             = 4800
) {

  include ::profiles
  include ::profiles::glassfish

  realize Group['glassfish']
  realize User['glassfish']

  domain { $title:
    ensure            => $ensure,
    user              => 'glassfish',
    asadminuser       => 'admin',
    passwordfile      => '/home/glassfish/asadmin.pass',
    portbase          => String($portbase),
    startoncreate     => false,
    enablesecureadmin => false,
    template          => undef,
    require           => [Group['glassfish'], User['glassfish']]
  }

  profiles::glassfish::domain::heap { $title:
    initial  => $initial_heap_size,
    maximum  => $maximum_heap_size,
    portbase => $portbase,
    require  => Profiles::Glassfish::Domain::Service[$title]
  }

  profiles::glassfish::domain::jmx { $title:
    ensure => $jmx ? {
                true  => 'present',
                false => 'absent'
              },
    portbase => $portbase,
    require  => Profiles::Glassfish::Domain::Service[$title]
  }

  profiles::glassfish::domain::newrelic { $title:
    ensure      => $newrelic ? {
                     true  => 'present',
                     false => 'absent'
                   },
    portbase    => $portbase,
    license_key => $newrelic_license_key,
    app_name    => $newrelic_app_name,
    require     => Profiles::Glassfish::Domain::Service[$title]
  }

  firewall { "400 accept glassfish domain ${title} HTTP traffic":
    proto  => 'tcp',
    dport  => String($portbase + 80),
    action => 'accept'
  }

  firewall { "400 accept glassfish domain ${title} HTTPS traffic":
    proto  => 'tcp',
    dport  => String($portbase + 81),
    action => 'accept'
  }

  cron { "Cleanup payara logs ${title}":
    command  => "/usr/bin/find /opt/payara/glassfish/domains/${title}/logs -type f -name \"server.log_*\" -mtime +7 -exec rm {} \\;",
    user     => 'root',
    hour     => '*',
    minute   => '15',
    weekday  => '*',
    monthday => '*',
    month    => '*'
  }

  profiles::glassfish::domain::service { $title:
    ensure  => $ensure,
    status  => $service_status,
    require => Domain[$title]
  }
}
