define profiles::glassfish::domain (
  Enum['present', 'absent']  $ensure         = 'present',
  Enum['running', 'stopped'] $service_status = 'running',
  Boolean                    $jmx            = true,
  Integer                    $portbase       = 4800
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

  if $jmx {
    profiles::glassfish::domain::jmx { $title:
      ensure   => 'present',
      portbase => $portbase,
      require  => Profiles::Glassfish::Domain::Service[$title]
    }
  } else {
    profiles::glassfish::domain::jmx { $title:
      ensure   => 'absent',
      portbase => $portbase,
      require  => Profiles::Glassfish::Domain::Service[$title]
    }
  }

  firewall { "400 accept glassfish domain ${title} traffic":
    proto  => 'tcp',
    dport  => String($portbase + 80),
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
