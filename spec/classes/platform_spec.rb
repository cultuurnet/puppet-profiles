describe 'profiles::platform' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with database_password => secret and servername => platform.example.com' do
        let(:params) { {
          'database_password' => 'secret',
          'servername'        => 'platform.example.com'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'without extra parameters' do
            let(:params) {
              super().merge({})
            }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::platform').with(
              'servername'    => 'platform.example.com',
              'serveraliases' => [],
              'sling_enabled' => false,
              'catch_mail'    => false,
              'deployment'    => true
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }

            it { is_expected.to contain_class('profiles::php') }
            it { is_expected.to contain_class('profiles::apache') }
            it { is_expected.to contain_class('profiles::mysql::server') }

            it { is_expected.not_to contain_class('profiles::mailpit') }

            it { is_expected.to contain_file('/var/www/platform-api').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_mysql_database('platform').with(
              'charset' => 'utf8mb4',
              'collate' => 'utf8mb4_unicode_ci'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('platform@platform').with(
              'password' => 'secret',
              'remote'   => true
            ) }

            it { is_expected.to contain_class('profiles::platform::deployment') }

            it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://platform.example.com').with(
              'basedir'              => '/var/www/platform-api',
              'public_web_directory' => 'public',
              'aliases'              => [],
              'socket_type'          => 'tcp'
            ) }

            it { is_expected.to contain_file('/var/www/platform-api').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/platform-api').that_requires('User[www-data]') }
            it { is_expected.to contain_mysql_database('platform').that_comes_before('Profiles::Mysql::App_user[platform@platform]') }
            it { is_expected.to contain_class('profiles::platform::deployment').that_subscribes_to('Class[profiles::php]') }
            it { is_expected.to contain_class('profiles::platform::deployment').that_requires('Profiles::Mysql::App_user[platform@platform]') }
          end
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_users_source'/) }
        end
      end

      context 'with database_password => foo, servername => myplatform.example.com, serveraliases => [foo.example.com, bar.example.com], catch_mail => true and deployment => false' do
        let(:params) { {
          'database_password' => 'foo',
          'servername'        => 'myplatform.example.com',
          'serveraliases'     => ['foo.example.com', 'bar.example.com'],
          'catch_mail'        => true,
          'deployment'        => false
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__mysql__app_user('platform@platform').with(
            'password' => 'foo',
            'remote'   => true
          ) }

          it { is_expected.not_to contain_class('profiles::platform::deployment') }

          it { is_expected.to contain_class('profiles::mailpit').with(
            'smtp_address' => '127.0.0.1',
            'smtp_port'    => 1025,
            'http_address' => '127.0.0.1',
            'http_port'    => 8025
          ) }

          it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://myplatform.example.com').with(
            'basedir'              => '/var/www/platform-api',
            'public_web_directory' => 'public',
            'aliases'              => ['foo.example.com', 'bar.example.com'],
            'socket_type'          => 'tcp'
          ) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_password'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
