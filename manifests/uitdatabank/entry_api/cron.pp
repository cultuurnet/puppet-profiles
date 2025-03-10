class profiles::uitdatabank::entry_api::cron (
  String  $basedir                           = '/var/www/udb3-backend',
  Boolean $schedule_process_duplicates       = false,
  Boolean $schedule_movie_fetcher            = false,
  Boolean $schedule_add_trailers             = false,
  Boolean $schedule_replay_mismatched_events = false
) inherits ::profiles {

  realize User['www-data']

  cron { 'uitdatabank_process_duplicates':
    ensure      => $schedule_process_duplicates ? {
                     true  => 'present',
                     false => 'absent'
                   },
    command     => "${basedir}/bin/udb3.php place:process-duplicates --force",
    environment => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be'],
    user        => 'www-data',
    minute      => '0',
    hour        => '5',
    weekday     => '1',
    require     => User['www-data']
  }

  cron { 'uitdatabank_movie_fetcher':
    ensure      => $schedule_movie_fetcher ? {
                     true  => 'present',
                     false => 'absent'
                   },
    command     => "${basedir}/bin/udb3.php movies:fetch --force",
    environment => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be,jonas.verhaeghe@publiq.be'],
    user        => 'www-data',
    minute      => '0',
    hour        => '4',
    weekday     => '1',
    require     => User['www-data']
  }

  cron { 'uitdatabank_add_trailers':
    ensure      => $schedule_add_trailers ? {
                     true  => 'present',
                     false => 'absent'
                   },
    command     => "${basedir}/bin/udb3.php movies:add-trailers -l",
    environment => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be,jonas.verhaeghe@publiq.be'],
    user        => 'www-data',
    minute      => '0',
    hour        => '6',
    weekday     => ['1', '4'],
    require     => User['www-data']
  }

  file { 'replay_mismatched_events.sh':
    ensure  => $schedule_replay_mismatched_events ? {
                 true  => 'file',
                 false => 'absent'
               },
    path    => '/usr/local/bin/replay_mismatched_events.sh',
    owner   => 'www-data',
    content => template('profiles/uitdatabank/entry_api/replay_mismatched_events.sh.erb'),
    mode    => '0744'
  }

  cron { 'uitdatabank_replay_mismatched_events':
    ensure      => $schedule_replay_mismatched_events ? {
                     true  => 'present',
                     false => 'absent'
                   },
    command     => "/usr/local/bin/replay_mismatched_events.sh ${basedir}/log/web.log.1",
    environment => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be,jonas.verhaeghe@publiq.be'],
    user        => 'www-data',
    minute      => '0',
    hour        => '7',
    require     => [File['replay_mismatched_events.sh'], User['www-data']]
  }
}
