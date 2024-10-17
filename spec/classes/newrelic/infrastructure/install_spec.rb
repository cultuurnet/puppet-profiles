describe 'profiles::newrelic::infrastructure::install' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::newrelic::infrastructure::install').with(
          'version' => 'latest'
        ) }

        it { is_expected.to contain_apt__source('newrelic-infra') }
        it { is_expected.to contain_package('newrelic-infra').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_apt__source('newrelic-infra').that_comes_before('Package[newrelic-infra]') }
      end

      context "with version => 1.2.3" do
        let(:params) { {
          'version' => '1.2.3'
        } }

        it { is_expected.to contain_package('newrelic-infra').with(
          'ensure' => '1.2.3'
        ) }
      end
    end
  end
end
