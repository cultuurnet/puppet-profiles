class profiles::uitdatabank::entry_api::amqp_listener_uitpas (
  Enum['present', 'absent'] $ensure  = 'present',
  String                    $basedir = '/var/www/udb3-backend'
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  systemd::unit_file { 'uitdatabank-amqp-listener-uitpas.service':
    ensure        => $ensure ? {
                       'absent'  => 'absent',
                       'present' => 'file'
                     },
    content       => template('profiles/uitdatabank/entry_api/uitdatabank-amqp-listener-uitpas.service.erb'),
    notify        => Service['uitdatabank-amqp-listener-uitpas']
  }

  service { 'uitdatabank-amqp-listener-uitpas':
    ensure     => $ensure ? {
                    'absent'  => 'stopped',
                    'present' => 'running'
                  },
    enable     => $ensure ? {
                    'absent'  => false,
                    'present' => true
                  },
    hasstatus  => true,
    require    => [Group['www-data'], User['www-data']]
  }
}
