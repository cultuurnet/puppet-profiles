class profiles::uitdatabank::entry_api::bulk_label_offer_worker (
  Enum['present', 'absent'] $ensure  = 'present',
  String                    $basedir = '/var/www/udb3-backend'
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']

  systemd::unit_file { 'uitdatabank-bulk-label-offer-worker.service':
    ensure        => $ensure ? {
                       'absent'  => 'absent',
                       'present' => 'file'
                     },
    content       => template('profiles/uitdatabank/entry_api/uitdatabank-bulk-label-offer-worker.service.erb'),
    notify        => Service['uitdatabank-bulk-label-offer-worker']
  }

  service { 'uitdatabank-bulk-label-offer-worker':
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
