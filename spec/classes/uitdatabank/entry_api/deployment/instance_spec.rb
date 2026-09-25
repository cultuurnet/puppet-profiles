describe 'profiles::uitdatabank::entry_api::deployment::instance' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').with(
            'version'                               => 'latest',
            'repository'                            => 'uitdatabank-entry-api',
            'api_keys_matched_to_client_ids_source' => nil,
            'amqp_listener_uitpas'                  => 'present',
            'bulk_label_offer_worker'               => 'present',
            'mail_worker'                           => 'present',
            'event_export_worker_count'             => 1,
            'puppetdb_url'                          => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_apt__source('uitdatabank-entry-api') }
          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_package('uitdatabank-entry-api').with(
            'ensure' => 'latest'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/config.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/config.php'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/config.allow_all.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/config.allow_all.php'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/config.client_permissions.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/config.client_permissions.php'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/config.api_keys_matched_to_client_ids.php').with(
            'ensure' => 'absent',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/config.api_keys_matched_to_client_ids.php'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/config.kinepolis.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/config.kinepolis.php'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/config.completeness.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/config.completeness.php'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/config.external_id_mapping_organizer.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/config.external_id_mapping_organizer.php'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/config.external_id_mapping_place.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/config.external_id_mapping_place.php'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/public.pem').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/public-uitidv1.pem'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/public-keycloak.pem').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/public-keycloak.pem'
          ) }

          it { is_expected.to contain_exec('uitdatabank-entry-api-db-migrate').with(
            'command'     => 'vendor/bin/doctrine-dbal --no-interaction migrations:migrate',
            'cwd'         => '/var/www/udb3-backend',
            'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/udb3-backend'],
            'refreshonly' => true
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

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::entry_api::deployment::instance').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_package('uitdatabank-entry-api').that_requires('Apt::Source[uitdatabank-entry-api]') }
          it { is_expected.to contain_package('uitdatabank-entry-api').that_notifies('Exec[uitdatabank-entry-api-db-migrate]') }
          it { is_expected.to contain_package('uitdatabank-entry-api').that_notifies('Service[uitdatabank-entry-api]') }
          it { is_expected.to contain_package('uitdatabank-entry-api').that_notifies('Profiles::Deployment::Versions[profiles::uitdatabank::entry_api::deployment::instance]') }

          [
            '/var/www/udb3-backend/config.php',
            '/var/www/udb3-backend/config.allow_all.php',
            '/var/www/udb3-backend/config.client_permissions.php',
            '/var/www/udb3-backend/config.api_keys_matched_to_client_ids.php',
            '/var/www/udb3-backend/config.kinepolis.php',
            '/var/www/udb3-backend/config.completeness.php',
            '/var/www/udb3-backend/config.external_id_mapping_organizer.php',
            '/var/www/udb3-backend/config.external_id_mapping_place.php',
            '/var/www/udb3-backend/public.pem',
            '/var/www/udb3-backend/public-keycloak.pem'
          ].each do |file_resource|
            it { is_expected.to contain_file(file_resource).that_requires('Group[www-data]') }
            it { is_expected.to contain_file(file_resource).that_requires('User[www-data]') }
            it { is_expected.to contain_file(file_resource).that_requires('Package[uitdatabank-entry-api]') }
            it { is_expected.to contain_file(file_resource).that_notifies('Service[uitdatabank-entry-api]') }
          end

          it { is_expected.to contain_exec('uitdatabank-entry-api-db-migrate').that_notifies('Service[uitdatabank-entry-api]') }
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

          it { is_expected.to contain_profiles__deployment__versions('profiles::uitdatabank::entry_api::deployment::instance').with(
            'puppetdb_url' => nil
          ) }
        end
      end

      context 'with version => 1.2.3, repository => foo, api_keys_matched_to_client_ids_source => appconfig/uitdatabank/udb3-backend/config.api_keys_matched_to_client_ids.php, amqp_listener_uitpas => absent, bulk_label_offer_worker => absent, mail_worker => absent and event_export_worker_count => 3' do
        let(:params) { {
          'version'                               => '1.2.3',
          'repository'                            => 'foo',
          'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-backend/config.api_keys_matched_to_client_ids.php',
          'amqp_listener_uitpas'                  => 'absent',
          'bulk_label_offer_worker'               => 'absent',
          'mail_worker'                           => 'absent',
          'event_export_worker_count'             => 3
        } }

        context 'with repository foo defined' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }
          let(:pre_condition) { [
            '@apt::source { "foo": location => "http://localhost", release => "focal", repos => "main" }',
          ] }

          it { is_expected.to contain_apt__source('foo') }

          it { is_expected.to contain_package('uitdatabank-entry-api').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_package('uitdatabank-entry-api').that_requires('Apt::Source[foo]') }

          it { is_expected.to contain_file('/var/www/udb3-backend/config.api_keys_matched_to_client_ids.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => '/etc/uitdatabank-entry-api/config.api_keys_matched_to_client_ids.php'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::amqp_listener_uitpas').with(
            'ensure' => 'absent'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::bulk_label_offer_worker').with(
            'ensure' => 'absent'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::mail_worker').with(
            'ensure' => 'absent'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::event_export_workers').with(
            'count' => 3
          ) }
        end
      end
    end
  end
end
