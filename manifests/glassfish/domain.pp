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
    startoncreate     => true,
    enablesecureadmin => false,
    template          => undef,
    require           => [Group['glassfish'], User['glassfish']]
  }

  profiles::glassfish::domain::service { $title:
    ensure  => $ensure,
    status  => $status,
    require => Domain[$title]
  }
}
