describe 'profiles::uitpas::balie_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => /tmp/config.yml" do
        let(:params) { {
          'config_source' => '/tmp/config.yml'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::balie_api::deployment').with(
          'config_source'      => '/tmp/config.yml',
          'version'            => 'latest',
          'repository'         => 'uitpas-balie-api',
          'puppetdb_url'       => nil
        ) }

        it { is_expected.to contain_apt__source('uitpas-balie-api') }
        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_package('uitpas-balie-api').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uitpas-balie-api-config').with(
          'ensure' => 'file',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'path'   => '/var/www/uitpas-balie-api/config.yml',
          'source' => '/tmp/config.yml'
        ) }

        it { is_expected.to contain_profiles__php__fpm_service_alias('uitpas-balie-api') }

        it { is_expected.to contain_service('uitpas-balie-api').with(
          'hasstatus'  => true,
          'hasrestart' => true,
          'restart'    => '/usr/bin/systemctl reload uitpas-balie-api'
        ) }

        it { is_expected.to contain_package('uitpas-balie-api').that_notifies('Profiles::Deployment::Versions[profiles::uitpas::balie_api::deployment]') }
        it { is_expected.to contain_package('uitpas-balie-api').that_requires('Apt::Source[uitpas-balie-api]') }
        it { is_expected.to contain_package('uitpas-balie-api').that_notifies('Service[uitpas-balie-api]') }
        it { is_expected.to contain_file('uitpas-balie-api-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitpas-balie-api-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitpas-balie-api-config').that_requires('Package[uitpas-balie-api]') }
        it { is_expected.to contain_file('uitpas-balie-api-config').that_notifies('Service[uitpas-balie-api]') }
        it { is_expected.to contain_service('uitpas-balie-api').that_requires('Profiles::Php::Fpm_service_alias[uitpas-balie-api]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::balie_api::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::balie_api::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context "with config_source => /tmp/myconfig.yml, version => 1.2.3, repository => myrepo and puppetdb_url => http://puppetdb.example.com:8080" do
        let(:params) { {
          'config_source' => '/tmp/myconfig.yml',
          'version'       => '1.2.3',
          'repository'    => 'myrepo',
          'puppetdb_url'  => 'http://puppetdb.example.com:8080'
        } }

        context 'with repository myrepo defined' do
          let(:pre_condition) { [
            '@apt::source { "myrepo": location => "http://localhost", release => "focal", repos => "main" }',
          ] }

          it { is_expected.to contain_apt__source('myrepo') }

          it { is_expected.to contain_package('uitpas-balie-api').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_file('uitpas-balie-api-config').with(
            'source' => '/tmp/myconfig.yml'
          ) }

          it { is_expected.to contain_package('uitpas-balie-api').that_requires('Apt::Source[myrepo]') }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitpas::balie_api::deployment').with(
            'puppetdb_url' => 'http://puppetdb.example.com:8080'
          ) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
