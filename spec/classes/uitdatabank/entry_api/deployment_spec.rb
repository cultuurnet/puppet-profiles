describe 'profiles::uitdatabank::entry_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:params) { {
        'config_source'                       => 'appconfig/uitdatabank/udb3-backend/config.php',
        'admin_permissions_source'             => 'appconfig/uitdatabank/udb3-backend/config.allow_all.php',
        'client_permissions_source'            => 'appconfig/uitdatabank/udb3-backend/config.client_permissions.php',
        'movie_fetcher_config_source'          => 'appconfig/uitdatabank/udb3-backend/config.kinepolis.php',
        'completeness_source'                  => 'appconfig/uitdatabank/udb3-backend/config.completeness.php',
        'externalid_mapping_organizer_source'  => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_organizer.php',
        'externalid_mapping_place_source'      => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_place.php',
        'pubkey_uitidv1_source'                => 'appconfig/uitdatabank/keys/public.pem',
        'pubkey_keycloak_source'               => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem'
      } }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with type => instance (the default)' do
          let(:pre_condition) { "class { 'profiles::uitdatabank::entry_api': database_password => 'secret', servername => 'entry-api.example.com', job_interface_servername => 'jobs.example.com', deployment => false }" }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment').with(
            'config_source'                        => 'appconfig/uitdatabank/udb3-backend/config.php',
            'admin_permissions_source'              => 'appconfig/uitdatabank/udb3-backend/config.allow_all.php',
            'client_permissions_source'             => 'appconfig/uitdatabank/udb3-backend/config.client_permissions.php',
            'movie_fetcher_config_source'           => 'appconfig/uitdatabank/udb3-backend/config.kinepolis.php',
            'completeness_source'                   => 'appconfig/uitdatabank/udb3-backend/config.completeness.php',
            'externalid_mapping_organizer_source'   => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_organizer.php',
            'externalid_mapping_place_source'       => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_place.php',
            'pubkey_uitidv1_source'                 => 'appconfig/uitdatabank/keys/public.pem',
            'pubkey_keycloak_source'                => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem',
            'api_keys_matched_to_client_ids_source' => nil,
            'amqp_listener_uitpas'                  => 'present',
            'bulk_label_offer_worker'                => 'present',
            'mail_worker'                            => 'present',
            'event_export_worker_count'              => 1
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').with(
            'config_source'                       => 'appconfig/uitdatabank/udb3-backend/config.php',
            'amqp_listener_uitpas'                 => 'present',
            'bulk_label_offer_worker'               => 'present',
            'mail_worker'                           => 'present',
            'event_export_worker_count'             => 1
          ) }

          it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::deployment::container') }
        end

        context 'with type => container' do
          let(:pre_condition) { "class { 'profiles::uitdatabank::entry_api': database_password => 'secret', servername => 'entry-api.example.com', job_interface_servername => 'jobs.example.com', deployment => false, type => 'container' }" }

          let(:params) { super().merge({ 'type' => 'container' }) }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::container').with(
            'config_source'                       => 'appconfig/uitdatabank/udb3-backend/config.php',
            'amqp_listener_uitpas'                 => 'present',
            'bulk_label_offer_worker'               => 'present',
            'mail_worker'                           => 'present',
            'event_export_worker_count'             => 1
          ) }

          it { is_expected.not_to contain_class('profiles::uitdatabank::entry_api::deployment::instance') }
        end

        context 'with amqp_listener_uitpas => absent, bulk_label_offer_worker => absent, mail_worker => absent, event_export_worker_count => 3 and api_keys_matched_to_client_ids_source set' do
          let(:pre_condition) { "class { 'profiles::uitdatabank::entry_api': database_password => 'secret', servername => 'entry-api.example.com', job_interface_servername => 'jobs.example.com', deployment => false }" }

          let(:params) { super().merge({
            'amqp_listener_uitpas'                  => 'absent',
            'bulk_label_offer_worker'               => 'absent',
            'mail_worker'                            => 'absent',
            'event_export_worker_count'              => 3,
            'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-backend/config.api_keys_matched_to_client_ids.php'
          }) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').with(
            'amqp_listener_uitpas'                  => 'absent',
            'bulk_label_offer_worker'                => 'absent',
            'mail_worker'                            => 'absent',
            'event_export_worker_count'              => 3,
            'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-backend/config.api_keys_matched_to_client_ids.php'
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
