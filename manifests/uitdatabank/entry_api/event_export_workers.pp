class profiles::uitdatabank::entry_api::event_export_workers (
  Integer[0] $count   = 1,
  String     $basedir = '/var/www/udb3-backend'
) inherits ::profiles {

  realize Group['www-data']
  realize User['www-data']
  realize File['/etc/puppetlabs/facter/facts.d']

  systemd::unit_file { 'uitdatabank-event-export-worker@.service':
    ensure        => $count ? {
                       0       => 'absent',
                       default => 'file'
                     },
    daemon_reload => false,
    content       => template('profiles/uitdatabank/entry_api/uitdatabank-event-export-worker@.service.erb'),
    notify        => [Systemd::Daemon_reload['uitdatabank-event-export-workers.target'], Service['uitdatabank-event-export-workers.target']]
  }

  systemd::unit_file { 'uitdatabank-event-export-workers.target':
    ensure        => $count ? {
                       0       => 'absent',
                       default => 'present'
                     },
    daemon_reload => false,
    content       => template('profiles/uitdatabank/entry_api/uitdatabank-event-export-workers.target.erb'),
    notify        => [Systemd::Daemon_reload['uitdatabank-event-export-workers.target'], Service['uitdatabank-event-export-workers.target']]
  }

  systemd::daemon_reload { 'uitdatabank-event-export-workers.target': }

  service { 'uitdatabank-event-export-workers.target':
    ensure     => $count ? {
                    0       => 'stopped',
                    default => 'running'
                  },
    enable     => true,
    hasstatus  => true,
    hasrestart => false,
    require    => [Group['www-data'], User['www-data'], Systemd::Daemon_reload['uitdatabank-event-export-workers.target']]
  }

  # When lowering the amount of event export workers, the highest numbered worker
  # services (above the new $count) remain running, due to the 'systemctl daemon-reload'
  # that runs before the target refresh. The fact below holds the old count and stops
  # any worker services that are not wanted by the target.

  file { 'uitdatabank_event_export_worker_count_external_fact':
    ensure  => 'file',
    path    => '/etc/puppetlabs/facter/facts.d/uitdatabank_event_export_worker_count.txt',
    content => "uitdatabank_event_export_worker_count=${count}",
    require => Service['uitdatabank-event-export-workers.target']
  }

  if $facts['uitdatabank_event_export_worker_count'] {
    if Integer($facts['uitdatabank_event_export_worker_count']) > $count {
      Integer[$count + 1, Integer($facts['uitdatabank_event_export_worker_count'])].each |$id| {
        service { "uitdatabank-event-export-worker@${id}.service":
          ensure  => 'stopped',
          require => Service['uitdatabank-event-export-workers.target']
        }
      }
    }
  }
}
