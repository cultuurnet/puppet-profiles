describe 'profiles::uitdatabank::search_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment').with(
          'version'        => 'latest',
          'repository'     => 'uitdatabank-search-api',
          'basedir'        => '/var/www/udb3-search-service',
          'data_migration' => false,
          'puppetdb_url'   => nil
        ) }

        it { is_expected.to contain_apt__source('uitdatabank-search-api') }
        it { is_expected.to contain_package('uitdatabank-search-api').with( 'ensure' => 'latest') }
        it { is_expected.to contain_profiles__php__fpm_service_alias('uitdatabank-search-api') }

        it { is_expected.to contain_service('uitdatabank-search-api').with(
          'hasstatus'  => true,
          'hasrestart' => true,
          'restart'    => '/usr/bin/systemctl reload uitdatabank-search-api'
        ) }

        it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::search_api::deployment]') }
        it { is_expected.to contain_package('uitdatabank-search-api').that_requires('Apt::Source[uitdatabank-search-api]') }
        it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_service('uitdatabank-search-api').that_requires('Profiles::Php::Fpm_service_alias[uitdatabank-search-api]') }

        it { is_expected.not_to contain_package('uitdatabank-search-api').that_notifies('Class[profiles::uitdatabank::search_api::data_migration]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::search_api::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::search_api::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context "with version => 1.2.3, repository => foo, basedir => '/var/www/foo', data_migration => true and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'version'        => '1.2.3',
          'repository'     => 'foo',
          'basedir'        => '/var/www/foo',
          'data_migration' => true,
          'puppetdb_url'   => 'http://example.com:8000'
        } }

        context "with repository foo and class profiles::uitdatank::search_api::data_migration defined" do
          let(:pre_condition) { [
            '@apt::source { "foo": location => "http://localhost", release => "focal", repos => "main" }',
            'class { "profiles::uitdatabank::search_api::data_migration": }'
          ] }

          it { is_expected.to contain_apt__source('foo') }

          it { is_expected.to contain_package('uitdatabank-search-api').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::search_api::deployment').with(
            'puppetdb_url' => 'http://example.com:8000'
          ) }

          it { is_expected.to contain_package('uitdatabank-search-api').that_requires('Apt::Source[foo]') }
          it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Class[profiles::uitdatabank::search_api::data_migration]') }
        end
      end
    end
  end
end
