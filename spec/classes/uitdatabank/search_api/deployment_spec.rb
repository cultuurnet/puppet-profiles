describe 'profiles::uitdatabank::search_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => appconfig/uitdatabank/udb3-search-service/config.yml, config_source_php => appconfig/uitdatabank/udb3-search-service/config.php, features_source => appconfig/uitdatabank/udb3-search-service/features.yml and pubkey_keycloak_source => appconfig/uitdatabank/keys/pubkey-keycloak.pem" do
        let(:params) { {
          'config_source'          => 'appconfig/uitdatabank/udb3-search-service/config.yml',
          'config_source_php'      => 'appconfig/uitdatabank/udb3-search-service/config.php',
          'features_source'        => 'appconfig/uitdatabank/udb3-search-service/features.yml',
          'pubkey_keycloak_source' => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment').with(
            'config_source'          => 'appconfig/uitdatabank/udb3-search-service/config.yml',
            'config_source_php'      => 'appconfig/uitdatabank/udb3-search-service/config.php',
            'features_source'        => 'appconfig/uitdatabank/udb3-search-service/features.yml',
            'version'                => 'latest',
            'repository'             => 'uitdatabank-search-api',
            'pubkey_keycloak_source' => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem',
            'region_mapping_source'  => 'appconfig/uitdatabank/udb3-search-service/mapping_region.json',
            'default_queries_source' => 'appconfig/uitdatabank/udb3-search-service/default_queries.php',
            'api_keys_matched_to_client_ids_source' => nil,
            'puppetdb_url'           => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_apt__source('uitdatabank-search-api') }
          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_package('uitdatabank-search-api').with(
            'ensure' => 'latest'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-config').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/var/www/udb3-search-service/config.yml',
            'content' => "key: value\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-features').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/var/www/udb3-search-service/features.yml',
            'content' => "feature: true\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').with(
            'ensure'  => 'absent',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/var/www/udb3-search-service/api_keys_matched_to_client_ids.php'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'path'   => '/var/www/udb3-search-service/facet_mapping_regions.yml',
            'source' => '/var/www/geojson-data/output/facet_mapping_regions.yml'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-autocomplete').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'path'   => '/var/www/udb3-search-service/web/autocomplete.json',
            'source' => '/var/www/geojson-data/output/autocomplete.json'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/var/www/udb3-search-service/src/ElasticSearch/Operations/json/mapping_region.json',
            'content' => "{ \"properties\": {} }\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/var/www/udb3-search-service/default_queries.php',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-pubkey-keycloak').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/var/www/udb3-search-service/public-keycloak.pem',
            'content' => "uitdatabank keycloak public key\n"
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

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::search_api::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::search_api::deployment]') }
          it { is_expected.to contain_package('uitdatabank-search-api').that_requires('Apt::Source[uitdatabank-search-api]') }
          it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Service[uitdatabank-search-api]') }
          it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
          it { is_expected.to contain_file('uitdatabank-search-api-config').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-config').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-config').that_requires('Package[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-config').that_notifies('Service[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-config').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
          it { is_expected.to contain_file('uitdatabank-search-api-features').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-features').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-features').that_requires('Package[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-features').that_notifies('Service[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-features').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
          it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_requires('Package[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_notifies('Service[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_requires('Package[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_notifies('Service[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_requires('Package[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_notifies('Service[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').that_requires('Package[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').that_notifies('Service[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').that_notifies('Class[profiles::uitdatabank::search_api::listeners]') }
          it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').that_requires('Package[uitdatabank-search-api]') }
          it { is_expected.to contain_service('uitdatabank-search-api').that_requires('Profiles::Php::Fpm_service_alias[uitdatabank-search-api]') }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment').with(
            'region_mapping_source'  => 'profiles/uitdatabank/search_api/mapping_region.json',
            'default_queries_source' => nil,
            'api_keys_matched_to_client_ids_source' => nil,
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::search_api::deployment').with(
            'puppetdb_url' => nil
          ) }
        end
      end

      context "with config_source => appconfig/uitdatabank/udb3-search-service/myconfig.yml, config_source => appconfig/uitdatabank/udb3-search-service/myconfig.php, features_source => appconfig/uitdatabank/udb3-search-service/myfeatures.yml, version => 1.2.3, repository => foo, pubkey_keycloak_source => appconfig/uitdatabank/keys/mypubkey-keycloak.pem, region_mapping_source => appconfig/uitdatabank/udb3-search-service/my_region_mapping.json, api_keys_matched_to_client_ids_source => appconfig/uitdatabank/udb3-search-service/api_keys.php, and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'config_source'          => 'appconfig/uitdatabank/udb3-search-service/myconfig.yml',
          'config_source_php'      => 'appconfig/uitdatabank/udb3-search-service/myconfig.php',
          'features_source'        => 'appconfig/uitdatabank/udb3-search-service/myfeatures.yml',
          'version'                => '1.2.3',
          'repository'             => 'foo',
          'pubkey_keycloak_source' => 'appconfig/uitdatabank/keys/mypubkey-keycloak.pem',
          'region_mapping_source'  => 'appconfig/uitdatabank/udb3-search-service/my_region_mapping.json',
          'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-search-service/api_keys.php',
          'puppetdb_url'           => 'http://example.com:8000'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with repository foo defined" do
            let(:pre_condition) { [
              '@apt::source { "foo": location => "http://localhost", release => "focal", repos => "main" }',
            ] }

            it { is_expected.to contain_apt__source('foo') }

            it { is_expected.to contain_package('uitdatabank-search-api').with(
              'ensure' => '1.2.3'
            ) }

            it { is_expected.to contain_file('uitdatabank-search-api-config').with(
              'ensure'  => 'file',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'path'    => '/var/www/udb3-search-service/config.yml',
              'content' => ''
            ) }

            it { is_expected.to contain_file('uitdatabank-search-api-features').with(
              'ensure'  => 'file',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'path'    => '/var/www/udb3-search-service/features.yml',
              'content' => ''
            ) }

            it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').with(
              'ensure'  => 'file',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'path'    => '/var/www/udb3-search-service/api_keys_matched_to_client_ids.php',
              'content' => ''
            ) }

            it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').with(
              'ensure'  => 'file',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'path'    => '/var/www/udb3-search-service/src/ElasticSearch/Operations/json/mapping_region.json',
              'content' => ''
            ) }

            it { is_expected.to contain_file('uitdatabank-search-api-default-queries').with(
              'ensure'  => 'file',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'path'    => '/var/www/udb3-search-service/default_queries.php',
              'content' => ''
            ) }

            it { is_expected.to contain_file('uitdatabank-search-api-pubkey-keycloak').with(
              'ensure'  => 'file',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'path'    => '/var/www/udb3-search-service/public-keycloak.pem',
              'content' => ''
            ) }

            it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').with(
              'command'     => '/var/www/udb3-search-service/bin/app.php udb3-core:reindex-permanent',
              'environment' => ['MAILTO=infra+cron@publiq.be'],
              'hour'        => '0',
              'minute'      => '0'
            ) }

            it { is_expected.to contain_class('profiles::uitdatabank::search_api::listeners').with(
              'basedir' => '/var/www/udb3-search-service'
            ) }

            it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::search_api::deployment').with(
              'puppetdb_url' => 'http://example.com:8000'
            ) }

            it { is_expected.to contain_package('uitdatabank-search-api').that_requires('Apt::Source[foo]') }
          end
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source_php'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'features_source'/) }
      end
    end
  end
end
