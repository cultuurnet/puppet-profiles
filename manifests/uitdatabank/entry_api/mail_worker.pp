class profiles::uitdatabank::entry_api::mail_worker (
  Enum['present', 'absent'] $ensure  = 'present',
  String                    $basedir = '/var/www/udb3-backend'
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  systemd::unit_file { 'uitdatabank-mail-worker.service':
    ensure        => $ensure ? {
                       'absent'  => 'absent',
                       'present' => 'file'
                     },
    content       => template('profiles/uitdatabank/entry_api/uitdatabank-mail-worker.service.erb'),
    notify        => Service['uitdatabank-mail-worker']
  }

  service { 'uitdatabank-mail-worker':
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
