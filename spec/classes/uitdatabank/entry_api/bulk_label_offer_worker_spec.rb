describe 'profiles::uitdatabank::entry_api::bulk_label_offer_worker' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::entry_api::bulk_label_offer_worker').with(
          'ensure'  => 'present',
          'basedir' => '/var/www/udb3-backend'
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-bulk-label-offer-worker.service').with(
          'ensure' => 'file'
        ) }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-bulk-label-offer-worker.service').with_content(/WorkingDirectory=\/var\/www\/udb3-backend/) }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-bulk-label-offer-worker.service').with_content(/Environment=APP_INCLUDE=\/var\/www\/udb3-backend\/worker_bootstrap.php/) }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-bulk-label-offer-worker.service').with_content(/Environment=QUEUE=bulk_label_offer/) }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-bulk-label-offer-worker.service').with_content(/ExecStart=\/usr\/bin\/php resque.php/) }

        it { is_expected.to contain_service('uitdatabank-bulk-label-offer-worker').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uitdatabank-bulk-label-offer-worker').that_requires('Group[www-data]') }
        it { is_expected.to contain_service('uitdatabank-bulk-label-offer-worker').that_requires('User[www-data]') }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-bulk-label-offer-worker.service').that_notifies('Service[uitdatabank-bulk-label-offer-worker]') }
      end

      context 'with basedir => /var/www/foo' do
        let(:params) { {
          'basedir' => '/var/www/foo'
        } }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-bulk-label-offer-worker.service').with_content(/WorkingDirectory=\/var\/www\/foo/) }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-bulk-label-offer-worker.service').with_content(/Environment=APP_INCLUDE=\/var\/www\/foo\/worker_bootstrap.php/) }
      end

      context 'with ensure => absent' do
        let(:params) { {
          'ensure' => 'absent'
        } }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-bulk-label-offer-worker.service').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_service('uitdatabank-bulk-label-offer-worker').with(
          'ensure'     => 'stopped',
          'enable'     => false,
          'hasstatus'  => true
        ) }
      end
    end
  end
end
