describe 'profiles::projectaanvraag::api::amqp_consumer' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::projectaanvraag::api::amqp_consumer').with(
          'ensure'  => 'present',
          'basedir' => '/var/www/projectaanvraag-api'
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_systemd__unit_file('projectaanvraag-api-amqp-consumer.service').with(
          'ensure' => 'file'
        ) }

        it { is_expected.to contain_systemd__unit_file('projectaanvraag-api-amqp-consumer.service').with_content(/WorkingDirectory=\/var\/www\/projectaanvraag-api/) }
        it { is_expected.to contain_systemd__unit_file('projectaanvraag-api-amqp-consumer.service').with_content(/ExecStart=\/usr\/bin\/php bin\/console projectaanvraag:consumer/) }

        it { is_expected.to contain_service('projectaanvraag-api-amqp-consumer').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('projectaanvraag-api-amqp-consumer').that_requires('Group[www-data]') }
        it { is_expected.to contain_service('projectaanvraag-api-amqp-consumer').that_requires('User[www-data]') }
        it { is_expected.to contain_systemd__unit_file('projectaanvraag-api-amqp-consumer.service').that_notifies('Service[projectaanvraag-api-amqp-consumer]') }
      end

      context 'with basedir => /var/www/foo' do
        let(:params) { {
          'basedir' => '/var/www/foo'
        } }

        it { is_expected.to contain_systemd__unit_file('projectaanvraag-api-amqp-consumer.service').with_content(/WorkingDirectory=\/var\/www\/foo/) }
      end

      context 'with ensure => absent' do
        let(:params) { {
          'ensure' => 'absent'
        } }

        it { is_expected.to contain_systemd__unit_file('projectaanvraag-api-amqp-consumer.service').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_service('projectaanvraag-api-amqp-consumer').with(
          'ensure'     => 'stopped',
          'enable'     => false,
          'hasstatus'  => true
        ) }
      end
    end
  end
end
