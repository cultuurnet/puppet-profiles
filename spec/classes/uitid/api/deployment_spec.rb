describe 'profiles::uitid::api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitid::api::deployment').with(
          'version'      => 'latest',
          'repository'   => 'uitid-api',
          'portbase'     => 4800,
          'puppetdb_url' => nil
        ) }

        it { is_expected.to contain_apt__source('uitid-api') }
        it { is_expected.to contain_user('glassfish') }

        it { is_expected.to contain_package('uitid-api').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_app('uitid-api').with(
          'ensure'        => 'present',
          'portbase'      => '4800',
          'user'          => 'glassfish',
          'passwordfile'  => '/home/glassfish/asadmin.pass',
          'contextroot'   => 'uitid',
          'precompilejsp' => false,
          'source'        => '/opt/uitid-api/uitid-api.war'
        ) }

        it { is_expected.to contain_package('uitid-api').that_requires('Apt::Source[uitid-api]') }
        it { is_expected.to contain_package('uitid-api').that_notifies('App[uitid-api]') }
        it { is_expected.to contain_package('uitid-api').that_notifies('Profiles::Deployment::Versions[profiles::uitid::api::deployment]') }
        it { is_expected.to contain_app('uitid-api').that_requires('User[glassfish]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitid::api::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitid::api::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context "with version => 3.2.1, portbase => 14800 and repository => uitid-api-alternative" do
        let(:params) { {
          'version'    => '3.2.1',
          'portbase'   => 14800,
          'repository' => 'uitid-api-alternative'
        } }

        context "with repository uitid-api-alternative defined" do
          let(:pre_condition) { '@apt::source { "uitid-api-alternative": location => "http://localhost", release => "focal", repos => "main" }' }

          it { is_expected.to contain_apt__source('uitid-api-alternative') }

          it { is_expected.to contain_package('uitid-api').with(
            'ensure' => '3.2.1'
          ) }

          it { is_expected.to contain_app('uitid-api').with(
            'ensure'        => 'present',
            'portbase'      => '14800',
            'user'          => 'glassfish',
            'passwordfile'  => '/home/glassfish/asadmin.pass',
            'contextroot'   => 'uitid',
            'precompilejsp' => false,
            'source'        => '/opt/uitid-api/uitid-api.war'
          ) }

          it { is_expected.to contain_package('uitid-api').that_requires('Apt::Source[uitid-api-alternative]') }
        end
      end
    end
  end
end
