describe 'profiles::mailpit' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        context 'in the acceptance environment' do
          let(:environment) { 'acceptance' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::mailpit').with(
            'smtp_address' => '127.0.0.1',
            'http_address' => '127.0.0.1'
          ) }

          it { is_expected.to contain_group('mailpit') }
          it { is_expected.to contain_user('mailpit') }
          it { is_expected.to contain_apt__source('publiq-tools') }

          it { is_expected.not_to contain_firewall('400 accept mailpit SMTP traffic') }

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

          it { is_expected.to contain_file('mailpit-service-defaults').with_content(/^SMTP_ADDRESS=127\.0\.0\.1\nSMTP_PORT=1025\nHTTP_ADDRESS=127\.0\.0\.1\nHTTP_PORT=8025\nENVIRONMENT=acceptance$/) }

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
      end

      context 'with smtp_address => 0.0.0.0 and http_address => 127.0.1.1' do
        let(:params) { {
          'smtp_address' => '0.0.0.0',
          'http_address' => '127.0.1.1'
        } }

        context 'in the testing environment' do
          let(:environment) { 'testing' }

          it { is_expected.to contain_firewall('400 accept mailpit SMTP traffic') }
          it { is_expected.to contain_file('mailpit-service-defaults').with_content(/^SMTP_ADDRESS=0\.0\.0\.0\nSMTP_PORT=1025\nHTTP_ADDRESS=127\.0\.1\.1\nHTTP_PORT=8025\nENVIRONMENT=testing$/) }
        end
      end
    end
  end
end
