describe 'profiles::uitdatabank::search_api::deployment::instance' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment::instance').with(
          'version'                               => 'latest',
          'repository'                            => 'uitdatabank-search-api',
          'default_queries_source'                => nil,
          'api_keys_matched_to_client_ids_source' => nil
        ) }

        it { is_expected.to contain_apt__source('uitdatabank-search-api') }

        it { is_expected.to contain_package('uitdatabank-search-api').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').with(
          'command'     => '/var/www/udb3-search-service/bin/app.php udb3-core:reindex-permanent',
          'environment' => ['MAILTO=infra+cron@publiq.be'],
          'hour'        => '0',
          'minute'      => '0'
        ) }

        it { is_expected.to contain_profiles__php__fpm_service_alias('uitdatabank-search-api') }

        it { is_expected.to contain_service('uitdatabank-search-api').with(
          'hasstatus'  => true,
          'hasrestart' => true,
          'restart'    => '/usr/bin/systemctl reload uitdatabank-search-api'
        ) }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::listeners').with(
          'basedir' => '/var/www/udb3-search-service'
        ) }

        it { is_expected.to contain_file('/var/www/udb3-search-service/config.php').with(
          'ensure' => 'link',
          'target' => '/etc/uitdatabank-search-api/config.php'
        ) }

        it { is_expected.to contain_file('/var/www/udb3-search-service/facet_mapping_regions.yml').with(
          'ensure' => 'link',
          'target' => '/var/www/geojson-data/output/facet_mapping_regions.yml'
        ) }

        it { is_expected.to contain_file('/var/www/udb3-search-service/facet_mapping_regions.php').with(
          'ensure' => 'link',
          'target' => '/var/www/geojson-data/output/facet_mapping_regions.php'
        ) }

        it { is_expected.to contain_file('/var/www/udb3-search-service/web/autocomplete.json').with(
          'ensure' => 'link',
          'target' => '/var/www/geojson-data/output/autocomplete.json'
        ) }

        it { is_expected.to contain_file('/var/www/udb3-search-service/src/ElasticSearch/Operations/json/mapping_region.json').with(
          'ensure' => 'link',
          'target' => '/etc/uitdatabank-search-api/mapping_region.json'
        ) }

        it { is_expected.to contain_file('/var/www/udb3-search-service/default_queries.php').with(
          'ensure' => 'absent',
          'target' => '/etc/uitdatabank-search-api/default_queries.php'
        ) }

        it { is_expected.to contain_file('/var/www/udb3-search-service/api_keys_matched_to_client_ids.php').with(
          'ensure' => 'absent',
          'target' => '/etc/uitdatabank-search-api/api_keys_matched_to_client_ids.php'
        ) }

        it { is_expected.to contain_file('/var/www/udb3-search-service/public-keycloak.pem').with(
          'ensure' => 'link',
          'target' => '/etc/uitdatabank-search-api/public-keycloak.pem',
          ) }

        it { is_expected.to contain_package('uitdatabank-search-api').that_requires('Apt::Source[uitdatabank-search-api]') }
        it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/config.php').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/config.php').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/config.php').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/facet_mapping_regions.yml').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/facet_mapping_regions.yml').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/facet_mapping_regions.yml').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/facet_mapping_regions.php').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/facet_mapping_regions.php').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/facet_mapping_regions.php').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/web/autocomplete.json').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/web/autocomplete.json').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/web/autocomplete.json').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/src/ElasticSearch/Operations/json/mapping_region.json').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/src/ElasticSearch/Operations/json/mapping_region.json').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/src/ElasticSearch/Operations/json/mapping_region.json').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/default_queries.php').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/default_queries.php').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/default_queries.php').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/api_keys_matched_to_client_ids.php').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/api_keys_matched_to_client_ids.php').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('/var/www/udb3-search-service/api_keys_matched_to_client_ids.php').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
        it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_service('uitdatabank-search-api').that_requires('Profiles::Php::Fpm_service_alias[uitdatabank-search-api]') }
      end

      context "with version => 1.2.3, repository => foo, default_queries_source => appconfig/uitdatabank/udb3-search-service/default_queries.php and api_keys_matched_to_client_ids_source => appconfig/uitdatabank/udb3-search-service/api_keys.php" do
        let(:params) { {
          'version'                               => '1.2.3',
          'repository'                            => 'foo',
          'default_queries_source'                => 'appconfig/uitdatabank/udb3-search-service/default_queries.php',
          'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-search-service/api_keys.php'
        } }

        context "with repository foo defined" do
          let(:pre_condition) { [
            '@apt::source { "foo": location => "http://localhost", release => "focal", repos => "main" }',
          ] }

          it { is_expected.to contain_apt__source('foo') }

          it { is_expected.to contain_package('uitdatabank-search-api').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-search-service/api_keys_matched_to_client_ids.php').with(
            'ensure' => 'link',
            'target' => '/etc/uitdatabank-search-api/api_keys_matched_to_client_ids.php',
          ) }

          it { is_expected.to contain_file('/var/www/udb3-search-service/default_queries.php').with(
            'ensure' => 'link',
            'target' => '/etc/uitdatabank-search-api/default_queries.php',
          ) }

          it { is_expected.to contain_package('uitdatabank-search-api').that_requires('Apt::Source[foo]') }
        end
      end
    end
  end
end
