describe 'profiles::uitdatabank::entry_api::event_export_workers' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::entry_api::event_export_workers').with(
          'count'   => 1,
          'basedir' => '/var/www/udb3-backend'
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }
        it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d') }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').with(
          'daemon_reload' => false
        ) }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').with_content(/PartOf=uitdatabank-event-export-workers.target/) }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').with_content(/WorkingDirectory=\/var\/www\/udb3-backend/) }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').with_content(/Environment=APP_INCLUDE=\/var\/www\/udb3-backend\/worker_bootstrap.php/) }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').with_content(/Environment=QUEUE=event_export/) }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').with_content(/ExecStart=\/usr\/bin\/php resque.php/) }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-workers.target').with(
          'daemon_reload' => false
        ) }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-workers.target').with_content(/Wants=uitdatabank-event-export-worker@1.service/) }

        it { is_expected.to contain_systemd__daemon_reload('uitdatabank-event-export-workers.target') }

        it { is_expected.to contain_service('uitdatabank-event-export-workers.target').with(
          'ensure'     => 'running',
          'enable'     => true,
          'hasstatus'  => true,
          'hasrestart' => false
        ) }

        it { is_expected.to contain_file('uitdatabank_event_export_worker_count_external_fact').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppetlabs/facter/facts.d/uitdatabank_event_export_worker_count.txt',
          'content' => 'uitdatabank_event_export_worker_count=1'
        ) }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').that_notifies('Service[uitdatabank-event-export-workers.target]') }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').that_notifies('Systemd::Daemon_reload[uitdatabank-event-export-workers.target]') }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-workers.target').that_notifies('Service[uitdatabank-event-export-workers.target]') }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-workers.target').that_notifies('Systemd::Daemon_reload[uitdatabank-event-export-workers.target]') }
        it { is_expected.to contain_service('uitdatabank-event-export-workers.target').that_requires('Group[www-data]') }
        it { is_expected.to contain_service('uitdatabank-event-export-workers.target').that_requires('User[www-data]') }
        it { is_expected.to contain_service('uitdatabank-event-export-workers.target').that_requires('Systemd::Daemon_reload[uitdatabank-event-export-workers.target]') }
        it { is_expected.to contain_file('uitdatabank_event_export_worker_count_external_fact').that_requires('Service[uitdatabank-event-export-workers.target]') }

        context 'with fact uitdatabank_event_export_worker_count => 2' do
          let(:facts) {
            super().merge({ 'uitdatabank_event_export_worker_count' => 2 })
          }

          it { is_expected.to contain_service('uitdatabank-event-export-worker@2.service').with(
            'ensure' => 'stopped'
          ) }

          it { is_expected.to contain_service('uitdatabank-event-export-worker@2.service').that_requires('Service[uitdatabank-event-export-workers.target]') }
        end
      end

      context 'with count => 0' do
        let(:params) { {
          'count' => 0
        } }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-workers.target').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_service('uitdatabank-event-export-workers.target').with(
          'ensure' => 'stopped',
          'enable' => 'false'
        ) }

        it { is_expected.to contain_file('uitdatabank_event_export_worker_count_external_fact').with(
          'content' => 'uitdatabank_event_export_worker_count=0'
        ) }

        context 'with fact uitdatabank_event_export_worker_count => 2' do
          let(:facts) {
            super().merge({ 'uitdatabank_event_export_worker_count' => 2 })
          }

          it { is_expected.to contain_service('uitdatabank-event-export-worker@1.service').with(
            'ensure' => 'stopped'
          ) }

          it { is_expected.to contain_service('uitdatabank-event-export-worker@2.service').with(
            'ensure' => 'stopped'
          ) }

          it { is_expected.to contain_service('uitdatabank-event-export-worker@1.service').that_requires('Service[uitdatabank-event-export-workers.target]') }
          it { is_expected.to contain_service('uitdatabank-event-export-worker@2.service').that_requires('Service[uitdatabank-event-export-workers.target]') }
        end
      end

      context 'with count => 3 and basedir => /var/www/foo' do
        let(:params) { {
          'count'   => 3,
          'basedir' => '/var/www/foo'
        } }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-workers.target').with_content(/Wants=uitdatabank-event-export-worker@1.service uitdatabank-event-export-worker@2.service uitdatabank-event-export-worker@3.service/) }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').with_content(/WorkingDirectory=\/var\/www\/foo/) }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-event-export-worker@.service').with_content(/Environment=APP_INCLUDE=\/var\/www\/foo\/worker_bootstrap.php/) }

        it { is_expected.to contain_file('uitdatabank_event_export_worker_count_external_fact').with(
          'content' => 'uitdatabank_event_export_worker_count=3'
        ) }

        context 'with fact uitdatabank_event_export_worker_count => 5' do
          let(:facts) {
            super().merge({ 'uitdatabank_event_export_worker_count' => 5 })
          }

          it { is_expected.to contain_service('uitdatabank-event-export-worker@4.service').with(
            'ensure' => 'stopped'
          ) }

          it { is_expected.to contain_service('uitdatabank-event-export-worker@5.service').with(
            'ensure' => 'stopped'
          ) }

          it { is_expected.to contain_service('uitdatabank-event-export-worker@4.service').that_requires('Service[uitdatabank-event-export-workers.target]') }
          it { is_expected.to contain_service('uitdatabank-event-export-worker@5.service').that_requires('Service[uitdatabank-event-export-workers.target]') }
        end
      end
    end
  end
end
