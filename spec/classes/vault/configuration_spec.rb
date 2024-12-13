describe 'profiles::vault::configuration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault::configuration').with(
          'service_address' => '127.0.0.1',
          'service_port'    => 8200
        ) }
      end

      context 'with service_address => 0.0.0.0 and service_port 18200' do
        let(:params) { {
          'service_address' => '0.0.0.0',
          'service_port'    => 18200
        } }
      end
    end
  end
end
