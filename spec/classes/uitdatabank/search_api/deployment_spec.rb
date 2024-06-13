describe 'profiles::uitdatabank::search_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => /tmp/config.yml, features_source => /tmp/features.yml, facilities_source => /tmp/facilities.yml, themes_source => /tmp/themes.yml, types_source => /tmp/types.yml and pubkey_auth0_source => /tmp/pubkey" do
        let(:params) { {
          'config_source'       => '/tmp/config.yml',
          'features_source'     => '/tmp/features.yml',
          'facilities_source'   => '/tmp/facilities.yml',
          'themes_source'       => '/tmp/themes.yml',
          'types_source'        => '/tmp/types.yml',
          'pubkey_auth0_source' => '/tmp/pubkey'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment').with(
          'config_source'          => '/tmp/config.yml',
          'features_source'        => '/tmp/features.yml',
          'facilities_source'      => '/tmp/facilities.yml',
          'themes_source'          => '/tmp/themes.yml',
          'types_source'           => '/tmp/types.yml',
          'version'                => 'latest',
          'repository'             => 'uitdatabank-search-api',
          'basedir'                => '/var/www/udb3-search-service',
          'pubkey_auth0_source'    => '/tmp/pubkey',
          'region_mapping_source'  => 'puppet:///modules/profiles/uitdatabank/search_api/mapping_region.json',
          'default_queries_source' => nil,
          'data_migration'         => false,
          'puppetdb_url'           => nil
        ) }

        it { is_expected.to contain_apt__source('uitdatabank-search-api') }
        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_package('uitdatabank-search-api').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uitdatabank-search-api-config').with(
          'ensure' => 'file',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'path'   => '/var/www/udb3-search-service/config.yml',
          'source' => '/tmp/config.yml'
        ) }

        it { is_expected.to contain_file('uitdatabank-search-api-features').with(
          'ensure' => 'file',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'path'   => '/var/www/udb3-search-service/features.yml',
          'source' => '/tmp/features.yml'
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

        it { is_expected.to contain_file('uitdatabank-search-api-pubkey-auth0').with(
          'ensure' => 'file',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'path'   => '/var/www/udb3-search-service/public-auth0.pem',
          'source' => '/tmp/pubkey'
        ) }

        it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').with(
          'ensure' => 'file',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'path'   => '/var/www/udb3-search-service/src/ElasticSearch/Operations/json/mapping_region.json',
          'source' => 'puppet:///modules/profiles/uitdatabank/search_api/mapping_region.json'
        ) }

        it { is_expected.not_to contain_file('uitdatabank-search-api-default-queries') }

        it { is_expected.to contain_profiles__uitdatabank__term_mapping('uitdatabank-search-api').with(
          'basedir'           => '/var/www/udb3-search-service',
          'facilities_source' => '/tmp/facilities.yml',
          'themes_source'     => '/tmp/themes.yml',
          'types_source'      => '/tmp/types.yml'
        ) }

        it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').with(
          'command'     => '/var/www/udb3-search-service/bin/app.php udb3-core:reindex-permanent',
          'environment' => ['MAILTO=infra@publiq.be'],
          'hour'        => '0',
          'minute'      => '0'
        ) }

        it { is_expected.to contain_profiles__php__fpm_service_alias('uitdatabank-search-api') }

        it { is_expected.to contain_service('uitdatabank-search-api').with(
          'hasstatus'  => true,
          'hasrestart' => true,
          'restart'    => '/usr/bin/systemctl reload uitdatabank-search-api'
        ) }

        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-api').with(
          'ensure'  => 'present',
          'command' => 'udb3-consume-api',
          'basedir' => '/var/www/udb3-search-service'
        ) }

        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-cli').with(
          'ensure'  => 'present',
          'command' => 'udb3-consume-cli',
          'basedir' => '/var/www/udb3-search-service'
        ) }

        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-related').with(
          'ensure'  => 'present',
          'command' => 'udb3-consume-related',
          'basedir' => '/var/www/udb3-search-service'
        ) }

        it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::search_api::deployment]') }
        it { is_expected.to contain_package('uitdatabank-search-api').that_requires('Apt::Source[uitdatabank-search-api]') }
        it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-api]') }
        it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-cli]') }
        it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-related]') }
        it { is_expected.to contain_file('uitdatabank-search-api-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-search-api-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-search-api-config').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-config').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-config').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-config').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-cli]') }
        it { is_expected.to contain_file('uitdatabank-search-api-config').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-related]') }
        it { is_expected.to contain_file('uitdatabank-search-api-features').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-search-api-features').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-search-api-features').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-features').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-features').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-features').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-cli]') }
        it { is_expected.to contain_file('uitdatabank-search-api-features').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-related]') }
        it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-cli]') }
        it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-related]') }
        it { is_expected.to contain_file('uitdatabank-search-api-pubkey-auth0').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-search-api-pubkey-auth0').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-search-api-pubkey-auth0').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-pubkey-auth0').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-pubkey-auth0').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-pubkey-auth0').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-cli]') }
        it { is_expected.to contain_file('uitdatabank-search-api-pubkey-auth0').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-related]') }
        it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_requires('Package[uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-api]') }
        it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-cli]') }
        it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-related]') }
        it { is_expected.to contain_profiles__uitdatabank__term_mapping('uitdatabank-search-api').that_notifies('Service[uitdatabank-search-api]') }
        it { is_expected.to contain_profiles__uitdatabank__term_mapping('uitdatabank-search-api').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-api]') }
        it { is_expected.to contain_profiles__uitdatabank__term_mapping('uitdatabank-search-api').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-cli]') }
        it { is_expected.to contain_profiles__uitdatabank__term_mapping('uitdatabank-search-api').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-related]') }
        it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').that_requires('Package[uitdatabank-search-api]') }
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

      context "with config_source => /foo/config.yml, features_source => /foo/features.yml, facilities_source => /tmp/facilities.txt, themes_source => /tmp/themes.txt, types_source => /tmp/types.txt, version => 1.2.3, repository => foo, basedir => '/var/www/foo', pubkey_auth0_source => /tmp/mypubkey, region_mapping_source => /tmp/mapping.json, default_queries_source => /tmp/default_queries.php, data_migration => true and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'config_source'          => '/foo/config.yml',
          'features_source'        => '/foo/features.yml',
          'facilities_source'      => '/tmp/facilities.txt',
          'themes_source'          => '/tmp/themes.txt',
          'types_source'           => '/tmp/types.txt',
          'version'                => '1.2.3',
          'repository'             => 'foo',
          'basedir'                => '/var/www/foo',
          'pubkey_auth0_source'    => '/tmp/mypubkey',
          'region_mapping_source'  => '/tmp/mapping.json',
          'default_queries_source' => '/tmp/default_queries.php',
          'data_migration'         => true,
          'puppetdb_url'           => 'http://example.com:8000'
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

          it { is_expected.to contain_file('uitdatabank-search-api-config').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'path'   => '/var/www/foo/config.yml',
            'source' => '/foo/config.yml'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-features').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'path'   => '/var/www/foo/features.yml',
            'source' => '/foo/features.yml'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-facet-mapping-regions').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'path'   => '/var/www/foo/facet_mapping_regions.yml',
            'source' => '/var/www/geojson-data/output/facet_mapping_regions.yml'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-autocomplete').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'path'   => '/var/www/foo/web/autocomplete.json',
            'source' => '/var/www/geojson-data/output/autocomplete.json'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-pubkey-auth0').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'path'   => '/var/www/foo/public-auth0.pem',
            'source' => '/tmp/mypubkey'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'path'   => '/var/www/foo/src/ElasticSearch/Operations/json/mapping_region.json',
            'source' => '/tmp/mapping.json'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'path'   => '/var/www/foo/default_queries.php',
            'source' => '/tmp/default_queries.php'
          ) }

          it { is_expected.to contain_profiles__uitdatabank__term_mapping('uitdatabank-search-api').with(
            'basedir'           => '/var/www/foo',
            'facilities_source' => '/tmp/facilities.txt',
            'themes_source'     => '/tmp/themes.txt',
            'types_source'      => '/tmp/types.txt'
          ) }

          it { is_expected.to contain_cron('uitdatabank-search-api-reindex-permanent').with(
            'command'     => '/var/www/foo/bin/app.php udb3-core:reindex-permanent',
            'environment' => ['MAILTO=infra@publiq.be'],
            'hour'        => '0',
            'minute'      => '0'
          ) }

          it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-api').with(
            'ensure'  => 'present',
            'command' => 'udb3-consume-api',
            'basedir' => '/var/www/foo'
          ) }

          it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-cli').with(
            'ensure'  => 'present',
            'command' => 'udb3-consume-cli',
            'basedir' => '/var/www/foo'
          ) }

          it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-related').with(
            'ensure'  => 'present',
            'command' => 'udb3-consume-related',
            'basedir' => '/var/www/foo'
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::search_api::deployment').with(
            'puppetdb_url' => 'http://example.com:8000'
          ) }

          it { is_expected.to contain_package('uitdatabank-search-api').that_requires('Apt::Source[foo]') }
          it { is_expected.to contain_package('uitdatabank-search-api').that_notifies('Class[profiles::uitdatabank::search_api::data_migration]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_requires('Package[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_notifies('Service[uitdatabank-search-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-api]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-cli]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_notifies('Profiles::Uitdatabank::Search_api::Listener[uitdatabank-consume-related]') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'features_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'facilities_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'themes_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'types_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'pubkey_auth0_source'/) }
      end
    end
  end
end
