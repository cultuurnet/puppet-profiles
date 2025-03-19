describe 'profiles::mailpit' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::mailpit').with(
          'smtp_address' => '127.0.0.1',
          'smtp_port'    => 1025,
          'http_address' => '127.0.0.1',
          'http_port'    => 8025
        ) }

        it { is_expected.to contain_group('mailpit') }
        it { is_expected.to contain_user('mailpit') }
        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_package('mailpit').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.to contain_file('mailpit-datadir').with(
          'ensure' => 'directory',
          'path'   => '/var/lib/mailpit',
          'owner'  => 'mailpit',
          'group'  => 'mailpit'
        ) }

        it { is_expected.to contain_file('mailpit-service-defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/mailpit'
        ) }

        it { is_expected.to contain_file('mailpit-service-defaults').with_content(/^SMTP_ADDRESS=127\.0\.0\.1\nSMTP_PORT=1025\nHTTP_ADDRESS=127\.0\.0\.1\nHTTP_PORT=8025$/) }

        it { is_expected.to contain_service('mailpit').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_package('mailpit').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_file('mailpit-service-defaults').that_notifies('Service[mailpit]') }
        it { is_expected.to contain_file('mailpit-datadir').that_requires('Group[mailpit]') }
        it { is_expected.to contain_file('mailpit-datadir').that_requires('User[mailpit]') }
        it { is_expected.to contain_service('mailpit').that_requires('Group[mailpit]') }
        it { is_expected.to contain_service('mailpit').that_requires('User[mailpit]') }
        it { is_expected.to contain_service('mailpit').that_requires('File[mailpit-datadir]') }
      end

      context 'with smtp_address => 127.0.1.1, smtp_port => 1234, http_address => 0.0.0.0 and http_port => 5678' do
        let(:params) { {
          'smtp_address' => '127.0.1.1',
          'smtp_port'    => 1234,
          'http_address' => '0.0.0.0',
          'http_port'    => 5678
        } }

        it { is_expected.to contain_file('mailpit-service-defaults').with_content(/^SMTP_ADDRESS=127\.0\.1\.1\nSMTP_PORT=1234\nHTTP_ADDRESS=0\.0\.0\.0\nHTTP_PORT=5678$/) }
      end
    end
  end
end
