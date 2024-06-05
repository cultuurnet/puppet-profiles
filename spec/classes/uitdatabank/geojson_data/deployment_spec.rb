describe 'profiles::uitdatabank::geojson_data::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::geojson_data::deployment').with(
          'version'        => 'latest',
          'repository'     => 'uitdatabank-geojson-data',
          'data_migration' => false,
          'puppetdb_url'   => nil
        ) }

        it { is_expected.to contain_apt__source('uitdatabank-geojson-data') }

        it { is_expected.to contain_package('uitdatabank-geojson-data').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uitdatabank-geojson-data').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::geojson_data::deployment]') }
        it { is_expected.to contain_package('uitdatabank-geojson-data').that_requires('Apt::Source[uitdatabank-geojson-data]') }

        it { is_expected.not_to contain_package('uitdatabank-geojson-data').that_notifies('Class[profiles::uitdatabank::search_api::data_migration]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::geojson_data::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::geojson_data::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context "with version => 1.2.3, repository => foo, data_migration => true and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'version'        => '1.2.3',
          'repository'     => 'foo',
          'data_migration' => true,
          'puppetdb_url'   => 'http://example.com:8000'
        } }

        context "with repository foo and class profiles::uitdatank::search_api::data_migration defined" do
          let(:pre_condition) { [
            '@apt::source { "foo": location => "http://localhost", release => "focal", repos => "main" }',
            'class { "profiles::uitdatabank::search_api::data_migration": }'
          ] }

          it { is_expected.to contain_apt__source('foo') }

          it { is_expected.to contain_package('uitdatabank-geojson-data').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::geojson_data::deployment').with(
            'puppetdb_url' => 'http://example.com:8000'
          ) }

          it { is_expected.to contain_package('uitdatabank-geojson-data').that_requires('Apt::Source[foo]') }
          it { is_expected.to contain_package('uitdatabank-geojson-data').that_notifies('Class[profiles::uitdatabank::search_api::data_migration]') }
        end
      end
    end
  end
end
