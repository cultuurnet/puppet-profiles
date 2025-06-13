describe 'profiles::uitdatabank::entry_api::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => appconfig/uitdatabank/udb3-backend/config.php, admin_permissions_source => appconfig/uitdatabank/udb3-backend/config.allow_all.php, client_permissions_source => appconfig/uitdatabank/udb3-backend/config.client_permissions.php, movie_fetcher_config_source => appconfig/uitdatabank/udb3-backend/config.kinepolis.php, completeness_source => appconfig/uitdatabank/udb3-backend/config.completeness.php, externalid_mapping_organizer_source => appconfig/uitdatabank/udb3-backend/config.external_id_mapping_organizer.php, externalid_mapping_place_source => appconfig/uitdatabank/udb3-backend/config.external_id_mapping_place.php, term_mapping_facilities_source => appconfig/uitdatabank/udb3-backend/config.term_mapping_facilities.php, term_mapping_themes_source => appconfig/uitdatabank/udb3-backend/config.term_mapping_themes.php, term_mapping_types_source => appconfig/uitdatabank/udb3-backend/config.term_mapping_types.php, pubkey_uitidv1_source => appconfig/uitdatabank/keys/public.pem and pubkey_keycloak_source => appconfig/uitdatabank/keys/pubkey-keycloak.pem' do
        let(:params) { {
          'config_source'                       => 'appconfig/uitdatabank/udb3-backend/config.php',
          'admin_permissions_source'            => 'appconfig/uitdatabank/udb3-backend/config.allow_all.php',
          'client_permissions_source'           => 'appconfig/uitdatabank/udb3-backend/config.client_permissions.php',
          'movie_fetcher_config_source'         => 'appconfig/uitdatabank/udb3-backend/config.kinepolis.php',
          'completeness_source'                 => 'appconfig/uitdatabank/udb3-backend/config.completeness.php',
          'externalid_mapping_organizer_source' => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_organizer.php',
          'externalid_mapping_place_source'     => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_place.php',
          'term_mapping_facilities_source'      => 'appconfig/uitdatabank/udb3-backend/config.term_mapping_facilities.php',
          'term_mapping_themes_source'          => 'appconfig/uitdatabank/udb3-backend/config.term_mapping_themes.php',
          'term_mapping_types_source'           => 'appconfig/uitdatabank/udb3-backend/config.term_mapping_types.php',
          'pubkey_uitidv1_source'               => 'appconfig/uitdatabank/keys/public.pem',
          'pubkey_keycloak_source'              => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment').with(
            'config_source'                       => 'appconfig/uitdatabank/udb3-backend/config.php',
            'admin_permissions_source'            => 'appconfig/uitdatabank/udb3-backend/config.allow_all.php',
            'client_permissions_source'           => 'appconfig/uitdatabank/udb3-backend/config.client_permissions.php',
            'movie_fetcher_config_source'         => 'appconfig/uitdatabank/udb3-backend/config.kinepolis.php',
            'completeness_source'                 => 'appconfig/uitdatabank/udb3-backend/config.completeness.php',
            'externalid_mapping_organizer_source' => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_organizer.php',
            'externalid_mapping_place_source'     => 'appconfig/uitdatabank/udb3-backend/config.external_id_mapping_place.php',
            'term_mapping_facilities_source'      => 'appconfig/uitdatabank/udb3-backend/config.term_mapping_facilities.php',
            'term_mapping_themes_source'          => 'appconfig/uitdatabank/udb3-backend/config.term_mapping_themes.php',
            'term_mapping_types_source'           => 'appconfig/uitdatabank/udb3-backend/config.term_mapping_types.php',
            'pubkey_uitidv1_source'               => 'appconfig/uitdatabank/keys/public.pem',
            'pubkey_keycloak_source'              => 'appconfig/uitdatabank/keys/pubkey-keycloak.pem',
            'version'                             => 'latest',
            'repository'                          => 'uitdatabank-entry-api',
            'bulk_label_offer_worker'             => 'present',
            'mail_worker'                         => 'present',
            'amqp_listener_uitpas'                => 'present',
            'event_export_worker_count'           => 1,
            'puppetdb_url'                        => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_apt__source('uitdatabank-entry-api') }
          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_package('uitdatabank-entry-api').with(
            'ensure' => 'latest'
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-config').with(
            'ensure'  => 'file',
            'path'    => '/var/www/udb3-backend/config.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "UiTdatabank entry API configuration\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-admin-permissions').with(
            'ensure'  => 'file',
            'path'    => '/var/www/udb3-backend/config.allow_all.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-client-permissions').with(
            'ensure'  => 'file',
            'path'    => '/var/www/udb3-backend/config.client_permissions.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-movie-fetcher-config').with(
            'ensure'  => 'file',
            'path'    => '/var/www/udb3-backend/config.kinepolis.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "UiTdatabank entry API movie fetcher configuration\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-completeness').with(
            'ensure'  => 'file',
            'path'    => '/var/www/udb3-backend/config.completeness.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').with(
            'ensure'  => 'file',
            'path'    => '/var/www/udb3-backend/config.external_id_mapping_organizer.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').with(
            'ensure'  => 'file',
            'path'    => '/var/www/udb3-backend/config.external_id_mapping_place.php',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => ''
          ) }

          it { is_expected.to contain_exec('uitdatabank-entry-api-db-migrate').with(
             'command'     => 'vendor/bin/doctrine-dbal --no-interaction migrations:migrate',
             'cwd'         => '/var/www/udb3-backend',
             'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/udb3-backend'],
             'refreshonly' => true
          ) }

          it { is_expected.to contain_profiles__uitdatabank__term_mapping('uitdatabank-entry-api').with(
            'basedir'                     => '/var/www/udb3-backend',
            'facilities_source'           => 'appconfig/uitdatabank/udb3-backend/config.term_mapping_facilities.php',
            'themes_source'               => 'appconfig/uitdatabank/udb3-backend/config.term_mapping_themes.php',
            'types_source'                => 'appconfig/uitdatabank/udb3-backend/config.term_mapping_types.php',
            'facilities_mapping_filename' => 'config.term_mapping_facilities.php',
            'themes_mapping_filename'     => 'config.term_mapping_themes.php',
            'types_mapping_filename'      => 'config.term_mapping_types.php'
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').with(
            'ensure'  => 'file',
            'path'    => '/var/www/udb3-backend/public.pem',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "uitdatabank public key\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').with(
            'ensure'  => 'file',
            'path'    => '/var/www/udb3-backend/public-keycloak.pem',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => "uitdatabank keycloak public key\n"
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

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::mail_worker').with(
            'ensure'  => 'present',
            'basedir' => '/var/www/udb3-backend'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::event_export_workers').with(
            'count'   => 1,
            'basedir' => '/var/www/udb3-backend'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::logrotate').with(
            'basedir' => '/var/www/udb3-backend'
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::entry_api::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
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
          it { is_expected.to contain_file('uitdatabank-entry-api-movie-fetcher-config').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-movie-fetcher-config').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-movie-fetcher-config').that_requires('Package[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-movie-fetcher-config').that_notifies('Service[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-completeness').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-completeness').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-completeness').that_requires('Package[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-completeness').that_notifies('Service[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').that_requires('Package[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-organizer').that_notifies('Service[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').that_requires('Package[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-externalid-mapping-place').that_notifies('Service[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').that_requires('Package[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-uitidv1').that_notifies('Service[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').that_requires('Package[uitdatabank-entry-api]') }
          it { is_expected.to contain_file('uitdatabank-entry-api-pubkey-keycloak').that_notifies('Service[uitdatabank-entry-api]') }
          it { is_expected.to contain_exec('uitdatabank-entry-api-db-migrate').that_notifies('Service[uitdatabank-entry-api]') }
          it { is_expected.to contain_profiles__uitdatabank__term_mapping('uitdatabank-entry-api').that_requires('Package[uitdatabank-entry-api]') }
          it { is_expected.to contain_profiles__uitdatabank__term_mapping('uitdatabank-entry-api').that_notifies('Service[uitdatabank-entry-api]') }
          it { is_expected.to contain_profiles__php__fpm_service_alias('uitdatabank-entry-api').that_notifies('Service[uitdatabank-entry-api]') }
          it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::amqp_listener_uitpas]') }
          it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::bulk_label_offer_worker]') }
          it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::mail_worker]') }
          it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::event_export_workers]') }
        end

        context 'without Terraform NFS mount hieradata' do
          let(:hiera_config) { 'spec/support/hiera/terraform_empty.yaml' }

          it { is_expected.not_to contain_profiles__nfs__mount('foo.fs-1234.efs.eu-west-1.amazonaws.com:/') }
        end

        context 'with Terraform NFS mount hieradata' do
          let(:hiera_config) { 'spec/support/hiera/terraform_common.yaml' }

          it { is_expected.to contain_profiles__nfs__mount('foo.fs-1234.efs.eu-west-1.amazonaws.com:/').with(
            'mountpoint'    => '/var/www/udb3-backend/web/downloads',
            'mount_options' => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2',
            'owner'         => 'www-data',
            'group'         => 'www-data'
          ) }

          it { is_expected.to contain_profiles__nfs__mount('foo.fs-1234.efs.eu-west-1.amazonaws.com:/').that_requires('Group[www-data]') }
          it { is_expected.to contain_profiles__nfs__mount('foo.fs-1234.efs.eu-west-1.amazonaws.com:/').that_requires('User[www-data]') }
          it { is_expected.to contain_profiles__nfs__mount('foo.fs-1234.efs.eu-west-1.amazonaws.com:/').that_requires('Package[uitdatabank-entry-api]') }
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::entry_api::deployment').with(
            'puppetdb_url' => nil
          ) }
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

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::amqp_listener_uitpas').with(
              'ensure'  => 'absent',
              'basedir' => '/var/www/udb3-backend'
            ) }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::bulk_label_offer_worker').with(
              'ensure'  => 'absent',
              'basedir' => '/var/www/udb3-backend'
            ) }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::mail_worker').with(
              'ensure'  => 'absent',
              'basedir' => '/var/www/udb3-backend'
            ) }

            it { is_expected.to contain_class('profiles::uitdatabank::entry_api::event_export_workers').with(
              'count'   => 0,
              'basedir' => '/var/www/udb3-backend'
            ) }

            context 'with event_export_worker_count => 3' do
              let(:params) { super().merge({
                'event_export_worker_count' => 3
              }) }

              it { is_expected.to contain_class('profiles::uitdatabank::entry_api::event_export_workers').with(
                'count' => 3
              ) }
            end
          end
        end
      end

      context 'with config_source => appconfig/uitdatabank/udb3-backend/my.config.php, admin_permissions_source => appconfig/uitdatabank/udb3-backend/config.my.allow_all.php, client_permissions_source => appconfig/uitdatabank/udb3-backend/config.my.client_permissions.php, movie_fetcher_config_source => appconfig/uitdatabank/udb3-backend/config.my.kinepolis.php, completeness_source => appconfig/uitdatabank/udb3-backend/config.my.completeness.php, externalid_mapping_organizer_source => appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_organizer.php, externalid_mapping_place_source => appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_place.php, term_mapping_facilities_source => appconfig/uitdatabank/term_mapping/config.term_mapping_facilities.php, term_mapping_themes_source => appconfig/uitdatabank/term_mapping/config.term_mapping_themes.php, term_mapping_types_source => appconfig/uitdatabank/term_mapping/config.term_mapping_types.php, pubkey_uitidv1_source => appconfig/uitdatabank/keys/my_public_key.pem and pubkey_keycloak_source => appconfig/uitdatabank/keys/mypubkey-keycloak.pem' do
        let(:params) { {
          'config_source'                       => 'appconfig/uitdatabank/udb3-backend/my.config.php',
          'admin_permissions_source'            => 'appconfig/uitdatabank/udb3-backend/config.my.allow_all.php',
          'client_permissions_source'           => 'appconfig/uitdatabank/udb3-backend/config.my.client_permissions.php',
          'movie_fetcher_config_source'         => 'appconfig/uitdatabank/udb3-backend/config.my.kinepolis.php',
          'completeness_source'                 => 'appconfig/uitdatabank/udb3-backend/config.my.completeness.php',
          'externalid_mapping_organizer_source' => 'appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_organizer.php',
          'externalid_mapping_place_source'     => 'appconfig/uitdatabank/udb3-backend/config.my.external_id_mapping_place.php',
          'term_mapping_facilities_source'      => 'appconfig/uitdatabank/term_mapping/config.term_mapping_facilities.php',
          'term_mapping_themes_source'          => 'appconfig/uitdatabank/term_mapping/config.term_mapping_themes.php',
          'term_mapping_types_source'           => 'appconfig/uitdatabank/term_mapping/config.term_mapping_types.php',
          'pubkey_uitidv1_source'               => 'appconfig/uitdatabank/keys/my_public_key.pem',
          'pubkey_keycloak_source'              => 'appconfig/uitdatabank/keys/mypubkey-keycloak.pem'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_file('uitdatabank-entry-api-config').with(
            'content' => ''
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-admin-permissions').with(
            'content' => "foo\n"
          ) }

          it { is_expected.to contain_file('uitdatabank-entry-api-client-permissions').with(
            'content' => "bar\n"
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
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'term_mapping_facilities_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'term_mapping_themes_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'term_mapping_types_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'pubkey_uitidv1_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'pubkey_keycloak_source'/) }
      end
    end
  end
end
