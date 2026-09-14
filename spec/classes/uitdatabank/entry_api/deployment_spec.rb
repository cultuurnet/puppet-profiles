describe 'profiles::uitdatabank::entry_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }
        let(:pre_condition) { "class { 'profiles::uitdatabank::entry_api': database_password => 'mypassword', servername => 'uitdatabank.example.com', job_interface_servername => 'jobs.example.com', deployment => false }" }

        context 'with config_source => appconfig/uitdatabank/udb3-backend/config.php, admin_permissions_source => appconfig/uitdatabank/udb3-backend/config.allow_all.php, client_permissions_source => appconfig/uitdatabank/udb3-backend/config.client_permissions.php, api_keys_matched_to_client_ids_source => config.api_keys_matched_to_client_ids.php, movie_fetcher_config_source => appconfig/uitdatabank/udb3-backend/config.kinepolis.php, completeness_source => appconfig/uitdatabank/udb3-backend/config.completeness.php, externalid_mapping_organizer_source => appconfig/uitdatabank/udb3-backend/config.external_id_mapping_organizer.php, externalid_mapping_place_source => appconfig/uitdatabank/udb3-backend/config.external_id_mapping_place.php, pubkey_uitidv1_source => appconfig/uitdatabank/keys/public.pem and pubkey_keycloak_source => appconfig/uitdatabank/keys/pubkey-keycloak.pem' do
          let(:params) { {
            'config_source'                         => 'appconfig/uitdatabank/udb3-backend/config.php',
            'admin_permissions_source'              => 'appconfig/uitdatabank/udb3-backend/config.allow_all.php',
            'client_permissions_source'             => 'appconfig/uitdatabank/udb3-backend/config.client_permissions.php',
            'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-backend/config.api_keys_matched_to_client_ids.php',
            'movie_fetcher_config_source'           => 'appconfig/uitdatabank/udb3-backend/config.kinepolis.php',
            'completeness_source'                   => 'appconfig/uitdatabank/udb3-backend/config.completeness.php',
            'externalid_mapping_organizer_source'   => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_organizer.php',
            'externalid_mapping_place_source'       => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_place.php',
            'pubkey_uitidv1_source'                 => 'appconfig/uitdatabank/keys/public.pem',
            'pubkey_keycloak_source'                => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment').with(
            'config_source'                         => 'appconfig/uitdatabank/udb3-backend/config.php',
            'admin_permissions_source'              => 'appconfig/uitdatabank/udb3-backend/config.allow_all.php',
            'client_permissions_source'             => 'appconfig/uitdatabank/udb3-backend/config.client_permissions.php',
            'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-backend/config.api_keys_matched_to_client_ids.php',
            'movie_fetcher_config_source'           => 'appconfig/uitdatabank/udb3-backend/config.kinepolis.php',
            'completeness_source'                   => 'appconfig/uitdatabank/udb3-backend/config.completeness.php',
            'externalid_mapping_organizer_source'   => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_organizer.php',
            'externalid_mapping_place_source'       => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_place.php',
            'pubkey_uitidv1_source'                 => 'appconfig/uitdatabank/keys/public.pem',
            'pubkey_keycloak_source'                => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem',
            'amqp_listener_uitpas'                  => 'present',
            'bulk_label_offer_worker'               => 'present',
            'mail_worker'                           => 'present',
            'event_export_worker_count'             => 1
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_class('profiles::php') }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').with(
            'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-backend/config.api_keys_matched_to_client_ids.php',
            'amqp_listener_uitpas'                  => 'present',
            'bulk_label_offer_worker'               => 'present',
            'mail_worker'                           => 'present',
            'event_export_worker_count'             => 1
          ) }

          it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::deployment::container') }

          it { is_expected.to contain_file('/etc/uitdatabank-entry-api').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755'
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-config').with(
            'ensure'  => 'file',
            'path'    => '/etc/uitdatabank-entry-api/config.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "UiTdatabank entry API configuration\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-admin-permissions').with(
            'ensure'  => 'file',
            'path'    => '/etc/uitdatabank-entry-api/config.allow_all.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-client-permissions').with(
            'ensure'  => 'file',
            'path'    => '/etc/uitdatabank-entry-api/config.client_permissions.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-api-keys-matched-to-client-ids').with(
            'ensure'  => 'file',
            'path'    => '/etc/uitdatabank-entry-api/config.api_keys_matched_to_client_ids.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-movie-fetcher-config').with(
            'ensure'  => 'file',
            'path'    => '/etc/uitdatabank-entry-api/config.kinepolis.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "UiTdatabank entry API movie fetcher configuration\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-completeness').with(
            'ensure'  => 'file',
            'path'    => '/etc/uitdatabank-entry-api/config.completeness.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').with(
            'ensure'  => 'file',
            'path'    => '/etc/uitdatabank-entry-api/config.external_id_mapping_organizer.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').with(
            'ensure'  => 'file',
            'path'    => '/etc/uitdatabank-entry-api/config.external_id_mapping_place.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').with(
            'ensure'  => 'file',
            'path'    => '/etc/uitdatabank-entry-api/public-uitidv1.pem',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "uitdatabank public key\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').with(
            'ensure'  => 'file',
            'path'    => '/etc/uitdatabank-entry-api/public-keycloak.pem',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "uitdatabank keycloak public key\n"
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').that_subscribes_to('Class[profiles::php]') }

          [
            'uitdatabank-entry-api-config',
            'uitdatabank-entry-api-admin-permissions',
            'uitdatabank-entry-api-client-permissions',
            'uitdatabank-entry-api-api-keys-matched-to-client-ids',
            'uitdatabank-entry-api-movie-fetcher-config',
            'uitdatabank-entry-api-completeness',
            'uitdatabank-entry-api-externalid-mapping-organizer',
            'uitdatabank-entry-api-externalid-mapping-place',
            'uitdatabank-entry-api-pubkey-uitidv1',
            'uitdatabank-entry-api-pubkey-keycloak'
          ].each do |file_resource|
            it { is_expected.to contain_file(file_resource).that_requires('Group[www-data]') }
            it { is_expected.to contain_file(file_resource).that_requires('User[www-data]') }
            it { is_expected.to contain_file(file_resource).that_notifies('Class[profiles::uitdatabank::entry_api::deployment::instance]') }
          end

          context 'without api_keys_matched_to_client_ids_source' do
            let(:params) { super().reject { |key, _value| key == 'api_keys_matched_to_client_ids_source' } }

            it { is_expected.to contain_file('uitdatabank-entry-api-api-keys-matched-to-client-ids').with(
              'ensure' => 'absent'
            ) }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').with(
              'api_keys_matched_to_client_ids_source' => nil
            ) }
          end

          context 'with amqp_listener_uitpas => absent, bulk_label_offer_worker => absent, mail_worker => absent and event_export_worker_count => 3' do
            let(:params) { super().merge({
              'amqp_listener_uitpas'      => 'absent',
              'bulk_label_offer_worker'   => 'absent',
              'mail_worker'               => 'absent',
              'event_export_worker_count' => 3
            }) }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').with(
              'amqp_listener_uitpas'      => 'absent',
              'bulk_label_offer_worker'   => 'absent',
              'mail_worker'               => 'absent',
              'event_export_worker_count' => 3
            ) }
          end

          context 'with type => container' do
            let(:pre_condition) { "class { 'profiles::uitdatabank::entry_api': database_password => 'mypassword', servername => 'uitdatabank.example.com', job_interface_servername => 'jobs.example.com', type => 'container', deployment => false }" }

            it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::deployment::instance') }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::container').with(
              'api_keys_matched_to_client_ids' => true,
              'amqp_listener_uitpas'           => 'present',
              'bulk_label_offer_worker'        => 'present',
              'mail_worker'                    => 'present',
              'event_export_worker_count'      => 1
            ) }

            it { is_expected.to contain_file('uitdatabank-entry-api-config').with(
              'ensure' => 'file',
              'path'   => '/etc/uitdatabank-entry-api/config.php',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_file('uitdatabank-entry-api-config').that_notifies('Class[profiles::uitdatabank::entry_api::deployment::container]') }
            it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').that_notifies('Class[profiles::uitdatabank::entry_api::deployment::container]') }

            context 'without api_keys_matched_to_client_ids_source' do
              let(:params) { super().reject { |key, _value| key == 'api_keys_matched_to_client_ids_source' } }

              it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::container').with(
                'api_keys_matched_to_client_ids' => false
              ) }
            end
          end
        end

        context 'with config_source => appconfig/uitdatabank/udb3-backend/my.config.php, admin_permissions_source => appconfig/uitdatabank/udb3-backend/config.my.allow_all.php, client_permissions_source => appconfig/uitdatabank/udb3-backend/config.my.client_permissions.php, api_keys_matched_to_client_ids_source => config.my.api_keys_matched_to_client_ids.php, movie_fetcher_config_source => appconfig/uitdatabank/udb3-backend/config.my.kinepolis.php, completeness_source => appconfig/uitdatabank/udb3-backend/config.my.completeness.php, externalid_mapping_organizer_source => appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_organizer.php, externalid_mapping_place_source => appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_place.php, pubkey_uitidv1_source => appconfig/uitdatabank/keys/my_public_key.pem and pubkey_keycloak_source => appconfig/uitdatabank/keys/mypubkey-keycloak.pem' do
          let(:params) { {
            'config_source'                         => 'appconfig/uitdatabank/udb3-backend/my.config.php',
            'admin_permissions_source'              => 'appconfig/uitdatabank/udb3-backend/config.my.allow_all.php',
            'client_permissions_source'             => 'appconfig/uitdatabank/udb3-backend/config.my.client_permissions.php',
            'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-backend/config.my.api_keys_matched_to_client_ids.php',
            'movie_fetcher_config_source'           => 'appconfig/uitdatabank/udb3-backend/config.my.kinepolis.php',
            'completeness_source'                   => 'appconfig/uitdatabank/udb3-backend/config.my.completeness.php',
            'externalid_mapping_organizer_source'   => 'appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_organizer.php',
            'externalid_mapping_place_source'       => 'appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_place.php',
            'pubkey_uitidv1_source'                 => 'appconfig/uitdatabank/keys/my_public_key.pem',
            'pubkey_keycloak_source'                => 'appconfig/uitdatabank/keys/mypubkey-keycloak.pem'
          } }

          it { is_expected.to contain_file('uitdatabank-entry-api-config').with(
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-admin-permissions').with(
            'content' => "foo\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-client-permissions').with(
            'content' => "bar\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-api-keys-matched-to-client-ids').with(
            'content' => "akci\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-movie-fetcher-config').with(
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-completeness').with(
            'content' => "baz\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').with(
            'content' => "quux\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').with(
            'content' => "snafu\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').with(
            'content' => "my_public_key\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').with(
            'content' => ''
          ) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_permissions_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'client_permissions_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'movie_fetcher_config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'completeness_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'externalid_mapping_place_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'externalid_mapping_organizer_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'pubkey_uitidv1_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'pubkey_keycloak_source'/) }
      end
    end
  end
end
