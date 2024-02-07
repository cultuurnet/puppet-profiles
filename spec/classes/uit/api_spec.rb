describe 'profiles::uit::api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => foo.example.com and database_password => secret' do
        let(:params) { {
          'servername'        => 'foo.example.com',
          'database_password' => 'secret'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uit::api').with(
            'servername'        => 'foo.example.com',
            'database_password' => 'secret',
            'serveraliases'     => [],
            'deployment'        => true,
            'service_port'      => 4000
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_class('profiles::nodejs') }
          it { is_expected.to contain_class('profiles::redis') }
          it { is_expected.to contain_class('profiles::mysql::server') }
          it { is_expected.to contain_class('profiles::apache') }

          it { is_expected.to contain_file('/var/www/uit-api').with(
            'ensure' => 'directory',
            'owner'  => 'www-data',
            'group'  => 'www-data'
          ) }

          it { is_expected.to contain_file('uit-api-log').with(
            'ensure' => 'directory',
            'owner'  => 'www-data',
            'group'  => 'www-data'
          ) }

          it { is_expected.to contain_mysql_database('uit_api').with(
            'charset' => 'utf8mb4',
            'collate' => 'utf8mb4_unicode_ci'
          )}

          it { is_expected.to contain_profiles__mysql__app_user('uit_api').with(
            'user'     => 'uit_api',
            'database' => 'uit_api',
            'password' => 'secret'
          ) }

          it { is_expected.to contain_class('profiles::uit::api::deployment').with(
             'service_port' => 4000
          ) }

          it { is_expected.to contain_file('/var/www/uit-api').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/var/www/uit-api').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uit-api-log').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('uit-api-log').that_requires('User[www-data]') }
          it { is_expected.to contain_file('uit-api-log').that_requires('File[/var/www/uit-api]') }
          it { is_expected.to contain_mysql_database('uit_api').that_requires('Class[profiles::mysql::server]') }
          it { is_expected.to contain_profiles__mysql__app_user('uit_api').that_requires('Mysql_database[uit_api]') }
          it { is_expected.to contain_profiles__mysql__app_user('uit_api').that_comes_before('Class[profiles::uit::api::deployment]') }
          it { is_expected.to contain_class('profiles::uit::api::deployment').that_requires('Class[profiles::nodejs]') }
          it { is_expected.to contain_class('profiles::uit::api::deployment').that_requires('Class[profiles::mysql::server]') }
          it { is_expected.to contain_class('profiles::uit::api::deployment').that_requires('Class[profiles::redis]') }
          it { is_expected.to contain_class('profiles::uit::api::deployment').that_requires('File[uit-api-log]') }
        end

        context 'with deployment => false' do
          let(:params) {
            super().merge( { 'deployment' => false } )
          }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::nodejs') }
          it { is_expected.to_not contain_class('profiles::uit::api::deployment') }
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context 'with servername => bar.example.com, serveraliases => [alias1.example.com, alias2.example.com], service_port => 4001 and database_password => notsosecret' do
        let(:params) { {
          'servername'        => 'bar.example.com',
          'serveraliases'     => ['alias1.example.com', 'alias2.example.com'],
          'service_port'      => 4001,
          'database_password' => 'notsosecret'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').with(
            'destination' => 'http://127.0.0.1:4001/',
            'aliases'     => ['alias1.example.com', 'alias2.example.com']
          ) }

          it { is_expected.to contain_class('profiles::uit::api::deployment').with(
             'service_port' => 4001
          ) }

          it { is_expected.to contain_profiles__mysql__app_user('uit_api').with(
            'user'     => 'uit_api',
            'database' => 'uit_api',
            'password' => 'notsosecret'
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').that_requires('Class[profiles::uit::api::deployment]') }
          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').that_requires('Class[profiles::apache]') }
          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').that_requires('File[/var/www/uit-api]') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_password'/) }
      end
    end
  end
end
