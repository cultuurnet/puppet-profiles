describe 'profiles::vault' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault').with(
          'version'         => 'latest',
          'auto_unseal'     => false,
          'service_status'  => 'running',
          'service_address' => '127.0.0.1'
        ) }

        it { is_expected.not_to contain_firewall('400 accept vault traffic') }

        it { is_expected.to contain_class('profiles::vault::install').with(
          'version' => 'latest'
        ) }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'service_address' => '127.0.0.1'
        ) }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status' => 'running'
        ) }

        it { is_expected.to contain_class('profiles::vault::seal').with(
          'auto_unseal' => false
        ) }

        it { is_expected.to contain_class('profiles::vault::install').that_comes_before('Class[profiles::vault::configuration]') }
        it { is_expected.to contain_class('profiles::vault::install').that_notifies('Class[profiles::vault::service]') }
        it { is_expected.to contain_class('profiles::vault::configuration').that_notifies('Class[profiles::vault::service]') }
        it { is_expected.to contain_class('profiles::vault::seal').that_requires('Class[profiles::vault::service]') }
      end

      context 'with version => 1.2.3, auto_unseal => true, service_status => stopped and service_address => 0.0.0.0' do
        let(:params) { {
          'version'         => '1.2.3',
          'auto_unseal'     => true,
          'service_status'  => 'stopped',
          'service_address' => '0.0.0.0'
        } }

        it { is_expected.to contain_firewall('400 accept vault traffic') }

        it { is_expected.to contain_class('profiles::vault::install').with(
          'version' => '1.2.3'
        ) }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'auto_unseal'     => true,
          'service_address' => '0.0.0.0'
        ) }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status' => 'stopped'
        ) }

        it { is_expected.not_to contain_class('profiles::vault::seal') }
      end
    end
  end
end
