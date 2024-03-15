describe 'profiles::newrelic::java' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to contain_class('profiles::newrelic::java').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_package('newrelic-java').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.to contain_package('newrelic-java').that_requires('Apt::Source[publiq-tools]') }
      end

      context "with ensure => 9.8.7" do
        let(:params) { { 'ensure' => '9.8.7' } }

        it { is_expected.to contain_package('newrelic-java').with(
          'ensure' => '9.8.1'
        ) }
      end
    end
  end
end
