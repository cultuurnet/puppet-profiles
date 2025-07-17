class profiles::projectaanvraag::api::amqp_consumer (
  Enum['present', 'absent'] $ensure  = 'present',
  String                    $basedir = '/var/www/projectaanvraag-api'
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  systemd::unit_file { 'projectaanvraag-api-amqp-consumer.service':
    ensure  => $ensure ? {
                 'absent'  => 'absent',
                 'present' => 'file'
               },
    content => template('profiles/projectaanvraag/api/projectaanvraag-api-amqp-consumer.service.erb'),
    notify  => Service['projectaanvraag-api-amqp-consumer']
  }

  service { 'projectaanvraag-api-amqp-consumer':
    ensure    => $ensure ? {
                   'absent'  => 'stopped',
                   'present' => 'running'
                 },
    enable    => $ensure ? {
                   'absent'  => false,
                   'present' => true
                 },
    hasstatus => true,
    require   => [Group['www-data'], User['www-data']]
  }
}
