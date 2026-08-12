describe 'profiles::uitdatabank::search_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }
        let(:pre_condition) { "class { 'profiles::uitdatabank::search_api': servername => 'search-api.example.com', deployment => false }" }

        context "with config_source => appconfig/uitdatabank/udb3-search-service/config.php and pubkey_keycloak_source => appconfig/uitdatabank/keys/pubkey-keycloak.pem" do
          let(:params) { {
            'config_source'          => 'appconfig/uitdatabank/udb3-search-service/config.php',
            'pubkey_keycloak_source' => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment').with(
            'config_source'                         => 'appconfig/uitdatabank/udb3-search-service/config.php',
            'pubkey_keycloak_source'                => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem',
            'region_mapping_source'                 => 'appconfig/uitdatabank/udb3-search-service/mapping_region.json',
            'default_queries_source'                => nil,
            'api_keys_matched_to_client_ids_source' => nil
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment::instance').with(
            'default_queries_source'                => nil,
            'api_keys_matched_to_client_ids_source' => nil
          ) }

          it { is_expected.not_to contain_class('profiles::uitdatabank::search_api::deployment::container') }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/config.php').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/api_keys_matched_to_client_ids.php').with(
            'ensure'  => 'absent',
            'owner'   => 'www-data',
            'group'   => 'www-data'
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/mapping_region.json').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "{ \"properties\": {} }\n"
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/default_queries.php').with(
            'ensure'  => 'absent',
            'owner'   => 'www-data',
            'group'   => 'www-data'
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/public-keycloak.pem').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "uitdatabank keycloak public key\n"
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment::instance').that_requires('Class[profiles::php]') }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/config.php').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/config.php').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/config.php').that_notifies('Class[profiles::uitdatabank::search_api::deployment::instance]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/mapping_region.json').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/mapping_region.json').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/mapping_region.json').that_notifies('Class[profiles::uitdatabank::search_api::deployment::instance]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/default_queries.php').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/default_queries.php').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/default_queries.php').that_notifies('Class[profiles::uitdatabank::search_api::deployment::instance]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/api_keys_matched_to_client_ids.php').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/api_keys_matched_to_client_ids.php').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/api_keys_matched_to_client_ids.php').that_notifies('Class[profiles::uitdatabank::search_api::deployment::instance]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/public-keycloak.pem').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/public-keycloak.pem').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/public-keycloak.pem').that_notifies('Class[profiles::uitdatabank::search_api::deployment::instance]') }
        end

        context "with type => container, config_source => appconfig/uitdatabank/udb3-search-service/myconfig.php, pubkey_keycloak_source => appconfig/uitdatabank/keys/mypubkey-keycloak.pem, region_mapping_source => appconfig/uitdatabank/udb3-search-service/my_region_mapping.json, default_queries_source => appconfig/uitdatabank/udb3-search-service/default_queries.php and api_keys_matched_to_client_ids_source => appconfig/uitdatabank/udb3-search-service/api_keys.php" do
          let(:pre_condition) { "class { 'profiles::uitdatabank::search_api': servername => 'search-api.example.com', type => 'container', deployment => false }" }

          let(:params) { {
            'config_source'                         => 'appconfig/uitdatabank/udb3-search-service/myconfig.php',
            'pubkey_keycloak_source'                => 'appconfig/uitdatabank/keys/mypubkey-keycloak.pem',
            'region_mapping_source'                 => 'appconfig/uitdatabank/udb3-search-service/my_region_mapping.json',
            'default_queries_source'                => 'appconfig/uitdatabank/udb3-search-service/default_queries.php',
            'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-search-service/api_keys.php'
          } }

          it { is_expected.not_to contain_class('profiles::uitdatabank::search_api::deployment::instance') }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::deployment::container').with(
            'api_keys_matched_to_client_ids' => true,
            'default_queries'                => true
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/config.php').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "<?php\n\nreturn [];\n"
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/api_keys_matched_to_client_ids.php').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/mapping_region.json').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/default_queries.php').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/public-keycloak.pem').with(
            'ensure'  => 'file',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-search-api/config.php').that_notifies('Class[profiles::uitdatabank::search_api::deployment::container]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/mapping_region.json').that_notifies('Class[profiles::uitdatabank::search_api::deployment::container]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/default_queries.php').that_notifies('Class[profiles::uitdatabank::search_api::deployment::container]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/api_keys_matched_to_client_ids.php').that_notifies('Class[profiles::uitdatabank::search_api::deployment::container]') }
          it { is_expected.to contain_file('/etc/uitdatabank-search-api/public-keycloak.pem').that_notifies('Class[profiles::uitdatabank::search_api::deployment::container]') }
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
