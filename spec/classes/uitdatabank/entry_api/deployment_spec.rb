describe 'profiles::uitdatabank::entry_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

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

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment').with(
            'type'                                  => 'instance',
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
            'bulk_label_offer_worker'               => 'present',
            'mail_worker'                           => 'present',
            'amqp_listener_uitpas'                  => 'present',
            'event_export_worker_count'             => 1
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').with(
            'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-backend/config.api_keys_matched_to_client_ids.php',
            'bulk_label_offer_worker'               => 'present',
            'mail_worker'                           => 'present',
            'amqp_listener_uitpas'                  => 'present',
            'event_export_worker_count'             => 1
          ) }

          it { is_expected.to contain_file('/etc/uitdatabank-entry-api').with(
            'ensure' => 'directory'
          ) }

          {
            'config.php'                                => "UiTdatabank entry API configuration\n",
            'config.allow_all.php'                      => '',
            'config.client_permissions.php'             => '',
            'config.api_keys_matched_to_client_ids.php' => '',
            'config.kinepolis.php'                      => "UiTdatabank entry API movie fetcher configuration\n",
            'config.completeness.php'                   => '',
            'config.external_id_mapping_organizer.php'  => '',
            'config.external_id_mapping_place.php'      => '',
            'public.pem'                                => "uitdatabank public key\n",
            'public-keycloak.pem'                       => "uitdatabank keycloak public key\n"
          }.each do |file, content|
            it { is_expected.to contain_file("/etc/uitdatabank-entry-api/#{file}").with(
              'ensure'  => 'file',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'content' => content
            ) }

            it { is_expected.to contain_file("/etc/uitdatabank-entry-api/#{file}").that_requires('Group[www-data]') }
            it { is_expected.to contain_file("/etc/uitdatabank-entry-api/#{file}").that_requires('User[www-data]') }
            it { is_expected.to contain_file("/etc/uitdatabank-entry-api/#{file}").that_notifies('Class[profiles::uitdatabank::entry_api::deployment::instance]') }
          end
        end

        context 'with bulk_label_offer_worker => absent, mail_worker => absent, amqp_listener_uitpas => absent and event_export_worker_count => 0' do
          let(:params) { super().merge( {
            'amqp_listener_uitpas'      => 'absent',
            'bulk_label_offer_worker'   => 'absent',
            'mail_worker'               => 'absent',
            'event_export_worker_count' => 0
          }) }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').with(
              'bulk_label_offer_worker'   => 'absent',
              'mail_worker'               => 'absent',
              'amqp_listener_uitpas'      => 'absent',
              'event_export_worker_count' => 0
            ) }
          end
        end

        context 'with type => container' do
          let(:params) { super().merge({ 'type' => 'container' }) }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            context 'with a docker image version tag available' do
              let(:pre_condition) { 'function ecr_docker_image_version_tag($parameter1, $parameter2) { return "2026.11.27.000000" }' }

              it { is_expected.to compile.with_all_deps }

              it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::deployment::instance') }

              it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::container').with(
                'api_keys_matched_to_client_ids' => true,
                'amqp_listener_uitpas'           => 'present',
                'bulk_label_offer_worker'        => 'present',
                'mail_worker'                    => 'present',
                'event_export_worker_count'      => 1
              ) }

              it { is_expected.to contain_file('/etc/uitdatabank-entry-api/config.php').that_notifies('Class[profiles::uitdatabank::entry_api::deployment::container]') }
              it { is_expected.to contain_file('/etc/uitdatabank-entry-api/public.pem').that_notifies('Class[profiles::uitdatabank::entry_api::deployment::container]') }
            end
          end
        end
      end

      context 'with config_source => appconfig/uitdatabank/udb3-backend/my.config.php, admin_permissions_source => appconfig/uitdatabank/udb3-backend/config.my.allow_all.php, client_permissions_source => appconfig/uitdatabank/udb3-backend/config.my.client_permissions.php, movie_fetcher_config_source => appconfig/uitdatabank/udb3-backend/config.my.kinepolis.php, completeness_source => appconfig/uitdatabank/udb3-backend/config.my.completeness.php, externalid_mapping_organizer_source => appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_organizer.php, externalid_mapping_place_source => appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_place.php, pubkey_uitidv1_source => appconfig/uitdatabank/keys/my_public_key.pem and pubkey_keycloak_source => appconfig/uitdatabank/keys/mypubkey-keycloak.pem' do
        let(:params) { {
          'config_source'                       => 'appconfig/uitdatabank/udb3-backend/my.config.php',
          'admin_permissions_source'            => 'appconfig/uitdatabank/udb3-backend/config.my.allow_all.php',
          'client_permissions_source'           => 'appconfig/uitdatabank/udb3-backend/config.my.client_permissions.php',
          'movie_fetcher_config_source'         => 'appconfig/uitdatabank/udb3-backend/config.my.kinepolis.php',
          'completeness_source'                 => 'appconfig/uitdatabank/udb3-backend/config.my.completeness.php',
          'externalid_mapping_organizer_source' => 'appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_organizer.php',
          'externalid_mapping_place_source'     => 'appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_place.php',
          'pubkey_uitidv1_source'               => 'appconfig/uitdatabank/keys/my_public_key.pem',
          'pubkey_keycloak_source'              => 'appconfig/uitdatabank/keys/mypubkey-keycloak.pem'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_file('/etc/uitdatabank-entry-api/config.php').with_content('') }
          it { is_expected.to contain_file('/etc/uitdatabank-entry-api/config.allow_all.php').with_content("foo\n") }
          it { is_expected.to contain_file('/etc/uitdatabank-entry-api/config.client_permissions.php').with_content("bar\n") }
          it { is_expected.to contain_file('/etc/uitdatabank-entry-api/config.api_keys_matched_to_client_ids.php').with_ensure('absent') }
          it { is_expected.to contain_file('/etc/uitdatabank-entry-api/config.kinepolis.php').with_content('') }
          it { is_expected.to contain_file('/etc/uitdatabank-entry-api/config.completeness.php').with_content("baz\n") }
          it { is_expected.to contain_file('/etc/uitdatabank-entry-api/config.external_id_mapping_organizer.php').with_content("quux\n") }
          it { is_expected.to contain_file('/etc/uitdatabank-entry-api/config.external_id_mapping_place.php').with_content("snafu\n") }
          it { is_expected.to contain_file('/etc/uitdatabank-entry-api/public.pem').with_content("my_public_key\n") }
          it { is_expected.to contain_file('/etc/uitdatabank-entry-api/public-keycloak.pem').with_content('') }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').with(
            'api_keys_matched_to_client_ids_source' => nil
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
