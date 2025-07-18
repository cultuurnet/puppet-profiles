describe 'profiles::projectaanvraag::api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with database_password => mypassword, mongodb_password => mysecret and servername => uitdatabank.example.com' do
          let(:params) { {
            'database_password' => 'mypassword',
            'mongodb_password'  => 'mysecret',
            'servername'        => 'projectaanvraag-api.example.com'
          } }

          context "with class profiles::mysql::server present" do
            let(:pre_condition) { 'include profiles::mysql::server' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::projectaanvraag::api').with(
              'database_password' => 'mypassword',
              'mongodb_password'  => 'mysecret',
              'database_host'     => '127.0.0.1',
              'servername'        => 'projectaanvraag-api.example.com',
              'serveraliases'     => [],
              'deployment'        => true
            ) }

            it { is_expected.to contain_class('profiles::mysql::server') }
            it { is_expected.to contain_class('profiles::redis') }
            it { is_expected.to contain_class('profiles::mongodb') }
            it { is_expected.to contain_class('profiles::apache') }
            it { is_expected.to contain_class('profiles::php') }
            it { is_expected.to contain_class('profiles::projectaanvraag::api::deployment').with(
              'database_name' => 'projectaanvraag'
            ) }

            it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://projectaanvraag-api.example.com').with(
              'basedir'              => '/var/www/projectaanvraag-api',
              'public_web_directory' => 'web',
              'aliases'              => []
            ) }

            it { is_expected.to contain_mongodb__db('widgets').with(
              'user'     => 'projectaanvraag',
              'password' => 'mysecret'
            ) }

            it { is_expected.to contain_mysql_database('projectaanvraag').with(
              'charset' => 'utf8mb4',
              'collate' => 'utf8mb4_0900_ai_ci'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('projectaanvraag@projectaanvraag').with(
              'password' => 'mypassword',
              'remote'   => false
            ) }

            it { is_expected.to contain_mysql_database('projectaanvraag').that_comes_before('Profiles::Mysql::App_user[projectaanvraag@projectaanvraag]') }
            it { is_expected.to contain_mysql_database('projectaanvraag').that_requires('Class[profiles::mysql::server]') }
            it { is_expected.to contain_profiles__mysql__app_user('projectaanvraag@projectaanvraag').that_comes_before('Class[profiles::projectaanvraag::api::deployment]') }
            it { is_expected.to contain_mongodb__db('widgets').that_requires('Class[profiles::mongodb]') }
            it { is_expected.to contain_mongodb__db('widgets').that_comes_before('Class[profiles::projectaanvraag::api::deployment]') }
            it { is_expected.to contain_class('profiles::redis').that_comes_before('Class[profiles::projectaanvraag::api::deployment]') }
            it { is_expected.to contain_class('profiles::mongodb').that_comes_before('Class[profiles::projectaanvraag::api::deployment]') }
            it { is_expected.to contain_class('profiles::php').that_notifies('Class[profiles::projectaanvraag::api::deployment]') }
          end
        end

        context 'with database_password => secret, mongodb_password => foo, database_host => foo.example.com, servername => bar.example.com, serveraliases => baz.example.com and deployment => false' do
          let(:params) { {
            'database_password' => 'secret',
            'mongodb_password'  => 'foo',
            'database_host'     => 'foo.example.com',
            'servername'        => 'bar.example.com',
            'serveraliases'     => 'baz.example.com',
            'deployment'        => false
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::mysql::remote_server').with(
            'host' => 'foo.example.com'
          ) }

          it { is_expected.not_to contain_class('profiles::projectaanvraag::api::deployment') }

          it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://bar.example.com').with(
            'basedir'              => '/var/www/projectaanvraag-api',
            'public_web_directory' => 'web',
            'aliases'              => 'baz.example.com'
          ) }

          it { is_expected.to contain_mongodb__db('widgets').with(
            'user'     => 'projectaanvraag',
            'password' => 'foo'
          ) }

          context "with fact mysqld_version => 8.0.33" do
            let(:facts) { facts.merge( { 'mysqld_version' => '8.0.33' } ) }

            it { is_expected.to contain_mysql_database('projectaanvraag').with(
              'charset' => 'utf8mb4',
              'collate' => 'utf8mb4_0900_ai_ci'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('projectaanvraag@projectaanvraag').with(
              'password' => 'secret',
              'remote'   => true
            ) }

            it { is_expected.to contain_mysql_database('projectaanvraag').that_comes_before('Profiles::Mysql::App_user[projectaanvraag@projectaanvraag]') }
          end

          context "without extra facts" do
            it { is_expected.not_to contain_mysql_database('projectaanvraag') }
            it { is_expected.not_to contain_profiles__mysql__app_user('projectaanvraag@projectaanvraag') }
          end
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
