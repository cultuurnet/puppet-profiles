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
          'service_status'  => 'running',
          'service_address' => '127.0.0.1',
          'service_port'    => 8200
        ) }

        it { is_expected.to contain_class('profiles::vault::install').with(
          'version' => 'latest'
        ) }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'service_address' => '127.0.0.1',
          'service_port'    => 8200
        ) }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status' => 'running'
        ) }

        it { is_expected.to contain_class('profiles::vault::install').that_comes_before('Class[profiles::vault::configuration]') }
        it { is_expected.to contain_class('profiles::vault::install').that_notifies('Class[profiles::vault::service]') }
        it { is_expected.to contain_class('profiles::vault::configuration').that_notifies('Class[profiles::vault::service]') }
      end

      context 'with version => 1.2.3, service_status => stopped, service_address => 0.0.0.0 and service_port 18200' do
        let(:params) { {
          'version'         => '1.2.3',
          'service_status'  => 'stopped',
          'service_address' => '0.0.0.0',
          'service_port'    => 18200
        } }

        it { is_expected.to contain_class('profiles::vault::install').with(
          'version' => '1.2.3'
        ) }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'service_address' => '0.0.0.0',
          'service_port'    => 18200
        ) }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status' => 'stopped'
        ) }
      end
    end
  end
end
