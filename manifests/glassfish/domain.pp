define profiles::glassfish::domain (
  Enum['present', 'absent']  $ensure   = 'present',
  Enum['running', 'stopped'] $status   = 'running',
  Integer                    $portbase = 4800
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

  firewall { "400 accept glassfish domain ${title} traffic":
    proto  => 'tcp',
    dport  => String($portbase + 80),
    action => 'accept'
  }

  profiles::glassfish::domain::service { $title:
    ensure  => $ensure,
    status  => $status,
    require => Domain[$title]
  }
}
