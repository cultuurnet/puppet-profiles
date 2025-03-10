describe 'profiles::uitdatabank::entry_api::cron' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::entry_api::cron').with(
          'basedir'                           => '/var/www/udb3-backend',
          'schedule_process_duplicates'       => false,
          'schedule_movie_fetcher'            => false,
          'schedule_add_trailers'             => false,
          'schedule_replay_mismatched_events' => false
        ) }

        it { is_expected.to contain_cron('uitdatabank_process_duplicates').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_cron('uitdatabank_movie_fetcher').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_cron('uitdatabank_add_trailers').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_cron('uitdatabank_replay_mismatched_events').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_file('replay_mismatched_events.sh').with(
          'ensure' => 'absent',
          'path'   => '/usr/local/bin/replay_mismatched_events.sh'
        ) }
      end

      context 'with schedule_process_duplicates => true, schedule_movie_fetcher => true, schedule_add_trailers => true and schedule_replay_mismatched_events => true' do
        let(:params) { {
          'schedule_process_duplicates'       => true,
          'schedule_movie_fetcher'            => true,
          'schedule_add_trailers'             => true,
          'schedule_replay_mismatched_events' => true
        } }

        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_cron('uitdatabank_process_duplicates').with(
          'ensure'      => 'present',
          'command'     => '/var/www/udb3-backend/bin/udb3.php place:process-duplicates --force',
          'environment' => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be'],
          'user'        => 'www-data',
          'minute'      => '0',
          'hour'        => '5',
          'weekday'     => '1'
        ) }

        it { is_expected.to contain_cron('uitdatabank_movie_fetcher').with(
          'ensure'      => 'present',
          'command'     => '/var/www/udb3-backend/bin/udb3.php movies:fetch --force',
          'environment' => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be,jonas.verhaeghe@publiq.be'],
          'user'        => 'www-data',
          'minute'      => '0',
          'hour'        => '4',
          'weekday'     => '1'
        ) }

        it { is_expected.to contain_cron('uitdatabank_add_trailers').with(
          'ensure'      => 'present',
          'command'     => '/var/www/udb3-backend/bin/udb3.php movies:add-trailers -l',
          'environment' => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be,jonas.verhaeghe@publiq.be'],
          'user'        => 'www-data',
          'minute'      => '0',
          'hour'        => '6',
          'weekday'     => ['1', '4']
        ) }

        it { is_expected.to contain_file('replay_mismatched_events.sh').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/replay_mismatched_events.sh',
          'owner'  => 'www-data',
          'mode'   => '0744'
        ) }

        it { is_expected.to contain_file('replay_mismatched_events.sh').with_content(/BASEDIR=\/var\/www\/udb3-backend/) }

        it { is_expected.to contain_cron('uitdatabank_replay_mismatched_events').with(
          'ensure'      => 'present',
          'command'     => '/usr/local/bin/replay_mismatched_events.sh /var/www/udb3-backend/log/web.log.1',
          'environment' => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be,jonas.verhaeghe@publiq.be'],
          'user'        => 'www-data',
          'minute'      => '0',
          'hour'        => '7'
        ) }

        it { is_expected.to contain_cron('uitdatabank_process_duplicates').that_requires('User[www-data]') }
        it { is_expected.to contain_cron('uitdatabank_movie_fetcher').that_requires('User[www-data]') }
        it { is_expected.to contain_cron('uitdatabank_add_trailers').that_requires('User[www-data]') }
        it { is_expected.to contain_cron('uitdatabank_replay_mismatched_events').that_requires('User[www-data]') }
        it { is_expected.to contain_cron('uitdatabank_replay_mismatched_events').that_requires('File[replay_mismatched_events.sh]') }

        context 'with basedir => /tmp' do
          let(:params) { super().merge({
            'basedir' => '/tmp'
          }) }

          it { is_expected.to contain_cron('uitdatabank_process_duplicates').with(
            'command' => '/tmp/bin/udb3.php place:process-duplicates --force'
          ) }

          it { is_expected.to contain_cron('uitdatabank_movie_fetcher').with(
            'command' => '/tmp/bin/udb3.php movies:fetch --force'
          ) }

          it { is_expected.to contain_cron('uitdatabank_add_trailers').with(
            'command' => '/tmp/bin/udb3.php movies:add-trailers -l'
          ) }

          it { is_expected.to contain_cron('uitdatabank_replay_mismatched_events').with(
            'command' => '/usr/local/bin/replay_mismatched_events.sh /tmp/log/web.log.1'
          ) }
        end
      end
    end
  end
end
