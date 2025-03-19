describe 'profiles::uitdatabank::entry_api::amqp_listener_uitpas' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::entry_api::amqp_listener_uitpas').with(
          'ensure'  => 'present',
          'basedir' => '/var/www/udb3-backend'
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-amqp-listener-uitpas.service').with(
          'ensure' => 'file'
        ) }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-amqp-listener-uitpas.service').with_content(/WorkingDirectory=\/var\/www\/udb3-backend/) }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-amqp-listener-uitpas.service').with_content(/ExecStart=\/usr\/bin\/php bin\/udb3.php amqp-listen-uitpas/) }

        it { is_expected.to contain_service('uitdatabank-amqp-listener-uitpas').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uitdatabank-amqp-listener-uitpas').that_requires('Group[www-data]') }
        it { is_expected.to contain_service('uitdatabank-amqp-listener-uitpas').that_requires('User[www-data]') }
        it { is_expected.to contain_systemd__unit_file('uitdatabank-amqp-listener-uitpas.service').that_notifies('Service[uitdatabank-amqp-listener-uitpas]') }
      end

      context 'with basedir => /var/www/foo' do
        let(:params) { {
          'basedir' => '/var/www/foo'
        } }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-amqp-listener-uitpas.service').with_content(/WorkingDirectory=\/var\/www\/foo/) }
      end

      context 'with ensure => absent' do
        let(:params) { {
          'ensure' => 'absent'
        } }

        it { is_expected.to contain_systemd__unit_file('uitdatabank-amqp-listener-uitpas.service').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_service('uitdatabank-amqp-listener-uitpas').with(
          'ensure'     => 'stopped',
          'enable'     => false,
          'hasstatus'  => true
        ) }
      end
    end
  end
end
