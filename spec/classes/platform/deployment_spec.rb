describe 'profiles::platform::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => appconfig/platform/env and admin_users_source => appconfig/platform/admin_users' do
        let(:params) { {
          'config_source'      => 'appconfig/platform/env',
          'admin_users_source' => 'appconfig/platform/nova_users.php'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'without extra parameters' do
            let(:params) {
              super().merge({})
            }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::platform::deployment').with(
              'config_source'               => 'appconfig/platform/env',
              'version'                     => 'latest',
              'repository'                  => 'platform-api',
              'search_expired_integrations' => false,
              'puppetdb_url'                => 'http://localhost:8081'
            ) }

            it { is_expected.to contain_apt__source('platform-api') }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }

            it { is_expected.to contain_package('platform-api').with(
              'ensure' => 'latest'
            ) }

            it { is_expected.to contain_file('platform-api-config').with(
              'ensure'  => 'file',
              'path'    => '/var/www/platform-api/.env',
              'owner'   => 'www-data',
              'group'   => 'www-data',
              'content' => "KEY=value\n"
            ) }

            it { is_expected.to contain_file('platform-api-admin-users').with(
              'ensure' => 'file',
              'path'   => '/var/www/platform-api/nova_users.php',
              'owner'  => 'www-data',
              'group'  => 'www-data',
              'content' => "<?php\n\ndeclare(strict_types=1);\n\nreturn [\n    'admin.user@publiq.be',\n];"
            ) }

            it { is_expected.to contain_cron('platform-search-expired-integrations').with(
              'ensure' => 'absent'
            ) }

            it { is_expected.to contain_package('platform-api').that_requires('Apt::Source[platform-api]') }
            it { is_expected.to contain_package('platform-api').that_notifies('Profiles::Deployment::Versions[profiles::platform::deployment]') }
            it { is_expected.to contain_file('platform-api-config').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('platform-api-config').that_requires('User[www-data]') }
            it { is_expected.to contain_file('platform-api-config').that_requires('Package[platform-api]') }
            it { is_expected.to contain_file('platform-api-admin-users').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('platform-api-admin-users').that_requires('User[www-data]') }
            it { is_expected.to contain_file('platform-api-admin-users').that_requires('Package[platform-api]') }
          end

          context 'with search_expired_integrations' do
            let(:params) { super().merge({
              'search_expired_integrations' => true
            }) }

            it { is_expected.to contain_cron('platform-search-expired-integrations').with(
              'ensure'      => 'present',
              'command'     => 'cd /var/www/platform-api; php artisan integration:search-expired-integrations --force',
              'environment' => ['MAILTO=infra+cron@publiq.be'],
              'user'        => 'www-data',
              'hour'        => '0',
              'minute'      => '0'
            ) }

            it { is_expected.to contain_cron('platform-search-expired-integrations').that_requires('Package[platform-api]') }
          end
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_class('profiles::platform::deployment').with(
            'puppetdb_url' => nil
          ) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_users_source'/) }
      end
    end
  end
end
