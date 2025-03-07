describe 'profiles::uitdatabank::entry_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => /foo.json, admin_permissions_source => /tmp/admin_permissions_source, client_permissions_source => /tmp/client_permissions_source, pubkey_uitidv1_source => /tmp/pub_uitidv1.pem, pubkey_keycloak_source => /tmp/pub_keycloak.pem, externalid_mapping_organizer_source => /tmp/externalid_organizer_source, externalid_mapping_place_source => /tmp/externalid_place_source, term_mapping_facilities_source => /tmp/facilities_source, term_mapping_themes_source => /tmp/themes_source and term_mapping_types_source => /tmp/types_source' do
        let(:params) { {
          'config_source'                       => '/foo.json',
          'admin_permissions_source'            => '/tmp/admin_permissions_source',
          'client_permissions_source'           => '/tmp/client_permissions_source',
          'pubkey_uitidv1_source'               => '/tmp/pub_uitidv1.pem',
          'pubkey_keycloak_source'              => '/tmp/pub_keycloak.pem',
          'externalid_mapping_organizer_source' => '/tmp/externalid_organizer_source',
          'externalid_mapping_place_source'     => '/tmp/externalid_place_source',
          'term_mapping_facilities_source'      => '/tmp/facilities_source',
          'term_mapping_themes_source'          => '/tmp/themes_source',
          'term_mapping_types_source'           => '/tmp/types_source'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment').with(
          'config_source'                       => '/foo.json',
          'admin_permissions_source'            => '/tmp/admin_permissions_source',
          'client_permissions_source'           => '/tmp/client_permissions_source',
          'pubkey_uitidv1_source'               => '/tmp/pub_uitidv1.pem',
          'pubkey_keycloak_source'              => '/tmp/pub_keycloak.pem',
          'externalid_mapping_organizer_source' => '/tmp/externalid_organizer_source',
          'externalid_mapping_place_source'     => '/tmp/externalid_place_source',
          'term_mapping_facilities_source'      => '/tmp/facilities_source',
          'term_mapping_themes_source'          => '/tmp/themes_source',
          'term_mapping_types_source'           => '/tmp/types_source',
          'version'                             => 'latest',
          'repository'                          => 'uitdatabank-entry-api',
          'bulk_label_offer_worker'             => 'present',
          'amqp_listener_uitpas'                => 'present',
          'event_export_worker_count'           => 1
        ) }

        it { is_expected.to contain_apt__source('uitdatabank-entry-api') }
        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_package('uitdatabank-entry-api').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/udb3-backend/config.php',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'source' => '/foo.json'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-admin-permissions').with(
          'ensure' => 'file',
          'path'   => '/var/www/udb3-backend/config.allow_all.php',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'source' => '/tmp/admin_permissions_source'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-client-permissions').with(
          'ensure' => 'file',
          'path'   => '/var/www/udb3-backend/config.client_permissions.php',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'source' => '/tmp/client_permissions_source'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').with(
          'ensure' => 'file',
          'path'   => '/var/www/udb3-backend/public.pem',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'source' => '/tmp/pub_uitidv1.pem'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').with(
          'ensure' => 'file',
          'path'   => '/var/www/udb3-backend/public-keycloak.pem',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'source' => '/tmp/pub_keycloak.pem'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').with(
          'ensure' => 'file',
          'path'   => '/var/www/udb3-backend/config.external_id_mapping_organizer.php',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'source' => '/tmp/externalid_organizer_source'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').with(
          'ensure' => 'file',
          'path'   => '/var/www/udb3-backend/config.external_id_mapping_place.php',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'source' => '/tmp/externalid_place_source'
        ) }

        it { is_expected.to contain_exec('uitdatabank-entry-api-db-migrate').with(
           'command'     => 'vendor/bin/doctrine-dbal --no-interaction migrations:migrate',
           'cwd'         => '/var/www/udb3-backend',
           'path'        => ['/var/www/udb3-backend'],
           'refreshonly' => true
        ) }

        it { is_expected.to contain_profiles__uitdatabank__terms('uitdatabank-entry-api').with(
          'directory'                 => '/var/www/udb3-backend',
          'facilities_mapping_source' => '/tmp/facilities_source',
          'themes_mapping_source'     => '/tmp/themes_source',
          'types_mapping_source'      => '/tmp/types_source'
        ) }

        it { is_expected.to contain_profiles__php__fpm_service_alias('uitdatabank-entry-api') }

        it { is_expected.to contain_service('uitdatabank-entry-api').with(
          'hasstatus'  => true,
          'hasrestart' => true,
          'restart'    => '/usr/bin/systemctl reload uitdatabank-entry-api'
        ) }

        it { is_expected.to contain_class('profiles::uitdatabank::entry_api::amqp_listener_uitpas').with(
          'ensure'  => 'present',
          'basedir' => '/var/www/udb3-backend'
        ) }

        it { is_expected.to contain_class('profiles::uitdatabank::entry_api::bulk_label_offer_worker').with(
          'ensure'  => 'present',
          'basedir' => '/var/www/udb3-backend'
        ) }

        it { is_expected.to contain_class('profiles::uitdatabank::entry_api::event_export_workers').with(
          'count'   => 1,
          'basedir' => '/var/www/udb3-backend'
        ) }

        it { is_expected.to contain_package('uitdatabank-entry-api').that_requires('Apt::Source[uitdatabank-entry-api]') }
        it { is_expected.to contain_package('uitdatabank-entry-api').that_notifies('Exec[uitdatabank-entry-api-db-migrate]') }
        it { is_expected.to contain_package('uitdatabank-entry-api').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_package('uitdatabank-entry-api').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::entry_api::deployment]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-config').that_requires('Package[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-config').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-admin-permissions').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-admin-permissions').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-admin-permissions').that_requires('Package[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-admin-permissions').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-client-permissions').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-client-permissions').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-client-permissions').that_requires('Package[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-client-permissions').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').that_requires('Package[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').that_requires('Package[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').that_requires('Package[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').that_requires('Package[uitdatabank-entry-api]') }
        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_exec('uitdatabank-entry-api-db-migrate').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_profiles__uitdatabank__terms('uitdatabank-entry-api').that_requires('Package[uitdatabank-entry-api]') }
        it { is_expected.to contain_profiles__uitdatabank__terms('uitdatabank-entry-api').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_profiles__php__fpm_service_alias('uitdatabank-entry-api').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::amqp_listener_uitpas]') }
        it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::bulk_label_offer_worker]') }
        it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::event_export_workers]') }

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::entry_api::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::entry_api::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end

        context 'with bulk_label_offer_worker => absent, amqp_listener_uitpas => absent and event_export_worker_count => 0' do
          let(:params) { super().merge( {
            'amqp_listener_uitpas'      => 'absent',
            'bulk_label_offer_worker'   => 'absent',
            'event_export_worker_count' => 0
          }) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::amqp_listener_uitpas').with(
            'ensure'  => 'absent',
            'basedir' => '/var/www/udb3-backend'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::bulk_label_offer_worker').with(
            'ensure'  => 'absent',
            'basedir' => '/var/www/udb3-backend'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::event_export_workers').with(
            'count'   => 0,
            'basedir' => '/var/www/udb3-backend'
          ) }
        end

        context 'with event_export_worker_count => 3' do
          let(:params) { super().merge({
            'event_export_worker_count' => 3
          }) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::event_export_workers').with(
            'count' => 3
          ) }
        end
      end

      context 'with config_source => /etc/bar.json, admin_permissions_source => /etc/admin_permissions_source, client_permissions_source => /etc/client_permissions_source, pubkey_uitidv1_source => /etc/pub_uitidv1.pem, pubkey_keycloak_source => /etc/pub_keycloak.pem, externalid_mapping_organizer_source => /etc/externalid_organizer_source, externalid_mapping_place_source => /etc/externalid_place_source, term_mapping_facilities_source => /etc/facilities_source, term_mapping_themes_source => /etc/themes_source and term_mapping_types_source => /etc/types_source' do
        let(:params) { {
          'config_source'                       => '/etc/bar.json',
          'admin_permissions_source'            => '/etc/admin_permissions_source',
          'client_permissions_source'           => '/etc/client_permissions_source',
          'pubkey_uitidv1_source'               => '/etc/pub_uitidv1.pem',
          'pubkey_keycloak_source'              => '/etc/pub_keycloak.pem',
          'externalid_mapping_organizer_source' => '/etc/externalid_organizer_source',
          'externalid_mapping_place_source'     => '/etc/externalid_place_source',
          'term_mapping_facilities_source'      => '/etc/facilities_source',
          'term_mapping_themes_source'          => '/etc/themes_source',
          'term_mapping_types_source'           => '/etc/types_source'
        } }

        it { is_expected.to contain_file('uitdatabank-entry-api-config').with(
          'source' => '/etc/bar.json'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-admin-permissions').with(
          'source' => '/etc/admin_permissions_source'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-client-permissions').with(
          'source' => '/etc/client_permissions_source'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').with(
          'source' => '/etc/pub_uitidv1.pem'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').with(
          'source' => '/etc/pub_keycloak.pem'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').with(
          'source' => '/etc/externalid_organizer_source'
        ) }

        it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').with(
          'source' => '/etc/externalid_place_source'
        ) }
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_permissions_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'client_permissions_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'externalid_mapping_place_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'externalid_mapping_organizer_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'term_mapping_facilities_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'term_mapping_themes_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'term_mapping_types_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'pubkey_uitidv1_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'pubkey_keycloak_source'/) }
      end
    end
  end
end
