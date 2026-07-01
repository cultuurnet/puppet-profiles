describe 'profiles::uitdatabank::search_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context "with config_source => appconfig/uitdatabank/udb3-search-service/config.php and pubkey_keycloak_source => appconfig/uitdatabank/keys/pubkey-keycloak.pem" do
          let(:params) { {
            'config_source'          => 'appconfig/uitdatabank/udb3-search-service/config.php',
            'pubkey_keycloak_source' => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment').with(
            'type'                                  => 'instance',
            'config_source'                         => 'appconfig/uitdatabank/udb3-search-service/config.php',
            'pubkey_keycloak_source'                => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem',
            'region_mapping_source'                 => 'appconfig/uitdatabank/udb3-search-service/mapping_region.json',
            'default_queries_source'                => nil,
            'api_keys_matched_to_client_ids_source' => nil
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_class('Profiles::Uitdatabank::Search_api::Deployment::Instance').with(
            'default_queries_source'                => nil,
            'api_keys_matched_to_client_ids_source' => nil
          ) }

          it { is_expected.not_to contain_class('Profiles::Uitdatabank::Search_api::Deployment::Container') }

          it { is_expected.to contain_file('uitdatabank-search-api-config').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/etc/uitdatabank-search-api/config.php',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').with(
            'ensure'  => 'absent',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/etc/uitdatabank-search-api/api_keys_matched_to_client_ids.php'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/etc/uitdatabank-search-api/mapping_region.json',
            'content' => "{ \"properties\": {} }\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').with(
            'ensure'  => 'absent',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/etc/uitdatabank-search-api/default_queries.php'
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-pubkey-keycloak').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/etc/uitdatabank-search-api/public-keycloak.pem',
            'content' => "uitdatabank keycloak public key\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-config').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-config').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-config').that_notifies('Class[profiles::uitdatabank::search_api::deployment::instance]') }
          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_notifies('Class[profiles::uitdatabank::search_api::deployment::instance]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_notifies('Class[profiles::uitdatabank::search_api::deployment::instance]') }
          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').that_notifies('Class[profiles::uitdatabank::search_api::deployment::instance]') }
          it { is_expected.to contain_file('uitdatabank-search-api-pubkey-keycloak').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-pubkey-keycloak').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-search-api-pubkey-keycloak').that_notifies('Class[profiles::uitdatabank::search_api::deployment::instance]') }
        end

        context "with type => container, config_source => appconfig/uitdatabank/udb3-search-service/myconfig.php, pubkey_keycloak_source => appconfig/uitdatabank/keys/mypubkey-keycloak.pem, region_mapping_source => appconfig/uitdatabank/udb3-search-service/my_region_mapping.json, default_queries_source => appconfig/uitdatabank/udb3-search-service/default_queries.php and api_keys_matched_to_client_ids_source => appconfig/uitdatabank/udb3-search-service/api_keys.php" do
          let(:params) { {
            'type'                                  => 'container',
            'config_source'                         => 'appconfig/uitdatabank/udb3-search-service/myconfig.php',
            'pubkey_keycloak_source'                => 'appconfig/uitdatabank/keys/mypubkey-keycloak.pem',
            'region_mapping_source'                 => 'appconfig/uitdatabank/udb3-search-service/my_region_mapping.json',
            'default_queries_source'                => 'appconfig/uitdatabank/udb3-search-service/default_queries.php',
            'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-search-service/api_keys.php'
          } }

          it { is_expected.not_to contain_class('Profiles::Uitdatabank::Search_api::Deployment::Instance') }

          it { is_expected.to contain_class('Profiles::Uitdatabank::Search_api::Deployment::Container') }

          it { is_expected.to contain_file('uitdatabank-search-api-config').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/etc/uitdatabank-search-api/config.php',
            'content' => "<?php\n\nreturn [];\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/etc/uitdatabank-search-api/api_keys_matched_to_client_ids.php',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/etc/uitdatabank-search-api/mapping_region.json',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/etc/uitdatabank-search-api/default_queries.php',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-pubkey-keycloak').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'path'    => '/etc/uitdatabank-search-api/public-keycloak.pem',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-search-api-config').that_notifies('Class[profiles::uitdatabank::search_api::deployment::container]') }
          it { is_expected.to contain_file('uitdatabank-search-api-region-mapping').that_notifies('Class[profiles::uitdatabank::search_api::deployment::container]') }
          it { is_expected.to contain_file('uitdatabank-search-api-default-queries').that_notifies('Class[profiles::uitdatabank::search_api::deployment::container]') }
          it { is_expected.to contain_file('uitdatabank-search-api-api-keys-matched-to-client-ids').that_notifies('Class[profiles::uitdatabank::search_api::deployment::container]') }
          it { is_expected.to contain_file('uitdatabank-search-api-pubkey-keycloak').that_notifies('Class[profiles::uitdatabank::search_api::deployment::container]') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'pubkey_keycloak_source'/) }
      end
    end
  end
end
