describe 'profiles::uitdatabank::entry_api::deployment::instance' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::entry_api::deployment::instance').with(
          'version'                               => 'latest',
          'repository'                            => 'uitdatabank-entry-api',
          'api_keys_matched_to_client_ids_source' => nil,
          'bulk_label_offer_worker'               => 'present',
          'mail_worker'                           => 'present',
          'amqp_listener_uitpas'                  => 'present',
          'event_export_worker_count'             => 1
        ) }

        it { is_expected.to contain_apt__source('uitdatabank-entry-api') }
        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_package('uitdatabank-entry-api').with(
          'ensure' => 'latest'
        ) }

        [
          'config.php',
          'config.allow_all.php',
          'config.client_permissions.php',
          'config.kinepolis.php',
          'config.completeness.php',
          'config.external_id_mapping_organizer.php',
          'config.external_id_mapping_place.php',
          'public.pem',
          'public-keycloak.pem'
        ].each do |file|
          it { is_expected.to contain_file("/var/www/udb3-backend/#{file}").with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'source' => "/etc/uitdatabank-entry-api/#{file}"
          ) }

          it { is_expected.to contain_file("/var/www/udb3-backend/#{file}").that_requires('Group[www-data]') }
          it { is_expected.to contain_file("/var/www/udb3-backend/#{file}").that_requires('User[www-data]') }
          it { is_expected.to contain_file("/var/www/udb3-backend/#{file}").that_requires('Package[uitdatabank-entry-api]') }
          it { is_expected.to contain_file("/var/www/udb3-backend/#{file}").that_notifies('Service[uitdatabank-entry-api]') }
        end

        it { is_expected.to contain_file('/var/www/udb3-backend/config.api_keys_matched_to_client_ids.php').with(
          'ensure' => 'absent',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'source' => '/etc/uitdatabank-entry-api/config.api_keys_matched_to_client_ids.php'
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

        it { is_expected.to contain_package('uitdatabank-entry-api').that_requires('Apt::Source[uitdatabank-entry-api]') }
        it { is_expected.to contain_package('uitdatabank-entry-api').that_notifies('Exec[uitdatabank-entry-api-db-migrate]') }
        it { is_expected.to contain_package('uitdatabank-entry-api').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_exec('uitdatabank-entry-api-db-migrate').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_profiles__php__fpm_service_alias('uitdatabank-entry-api').that_notifies('Service[uitdatabank-entry-api]') }
        it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::amqp_listener_uitpas]') }
        it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::bulk_label_offer_worker]') }
        it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::mail_worker]') }
        it { is_expected.to contain_service('uitdatabank-entry-api').that_notifies('Class[profiles::uitdatabank::entry_api::event_export_workers]') }

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
      end

      context 'with version => 1.2.3, repository => foo, api_keys_matched_to_client_ids_source => appconfig/uitdatabank/udb3-backend/config.api_keys_matched_to_client_ids.php, bulk_label_offer_worker => absent, mail_worker => absent, amqp_listener_uitpas => absent and event_export_worker_count => 3' do
        let(:params) { {
          'version'                               => '1.2.3',
          'repository'                            => 'foo',
          'api_keys_matched_to_client_ids_source' => 'appconfig/uitdatabank/udb3-backend/config.api_keys_matched_to_client_ids.php',
          'bulk_label_offer_worker'               => 'absent',
          'mail_worker'                           => 'absent',
          'amqp_listener_uitpas'                  => 'absent',
          'event_export_worker_count'             => 3
        } }

        context 'with repository foo defined' do
          let(:pre_condition) { '@apt::source { "foo": location => "http://localhost", release => "focal", repos => "main" }' }

          it { is_expected.to contain_apt__source('foo') }

          it { is_expected.to contain_package('uitdatabank-entry-api').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_file('/var/www/udb3-backend/config.api_keys_matched_to_client_ids.php').with(
            'ensure' => 'file',
            'source' => '/etc/uitdatabank-entry-api/config.api_keys_matched_to_client_ids.php'
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::amqp_listener_uitpas').with_ensure('absent') }
          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::bulk_label_offer_worker').with_ensure('absent') }
          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::mail_worker').with_ensure('absent') }
          it { is_expected.to contain_class('profiles::uitdatabank::entry_api::event_export_workers').with_count(3) }

          it { is_expected.to contain_package('uitdatabank-entry-api').that_requires('Apt::Source[foo]') }
        end
      end
    end
  end
end
