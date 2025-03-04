describe 'profiles::newrelic::infrastructure::service' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::newrelic::infrastructure::service').with(
          'status' => 'running'
        ) }

        it { is_expected.to contain_service('newrelic-infra').with(
          'ensure'    => 'running',
          'hasstatus' => true,
          'enable'    => true
        ) }
      end

      context "with status => stopped" do
        let(:params) { {
          'status' => 'stopped'
        } }

        it { is_expected.to contain_service('newrelic-infra').with(
          'ensure'    => 'stopped',
          'hasstatus' => true,
          'enable'    => false
        ) }
      end

      context "with status => foo" do
        let(:params) { {
          'status' => 'foo'
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'status' expects a match for Enum\['running', 'stopped'\]/) }
      end
    end
  end
end
