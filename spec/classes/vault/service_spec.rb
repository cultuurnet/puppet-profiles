describe 'profiles::vault::service' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::vault::service').with(
          'service_status'  => 'running'
        ) }

        it { is_expected.to contain_service('vault').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }
      end

      context 'with service_status => stopped' do
        let(:params) { {
          'service_status' => 'stopped'
        } }

        it { is_expected.to contain_service('vault').with(
          'ensure'    => 'stopped',
          'enable'    => false,
          'hasstatus' => true
        ) }
      end
    end
  end
end
