describe 'profiles::uitpas::api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with database_password => mypassword" do
        let(:params) { {
          'database_password' => 'mypassword'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::api').with(
          'database_password' => 'mypassword',
          'database_host'     => '127.0.0.1',
          'deployment'        => true,
          'portbase'          => 4800,
          'service_status'    => 'running'
        ) }

        it { is_expected.to contain_group('glassfish') }
        it { is_expected.to contain_user('glassfish') }

        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_package('liquibase').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('mysql-connector-j').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_class('profiles::java') }
        it { is_expected.to contain_class('profiles::glassfish') }
        it { is_expected.to contain_class('profiles::mysql::server') }

        it { is_expected.to contain_mysql_database('uitpas_api').with(
          'charset' => 'utf8mb4',
          'collate' => 'utf8mb4_unicode_ci'
        ) }

        it { is_expected.to contain_profiles__mysql__app_user('uitpas_api').with(
          'database' => 'uitpas_api',
          'password' => 'mypassword'
        ) }

        it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').with(
          'ensure'              => 'present',
          'user'                => 'glassfish',
          'passwordfile'        => '/home/glassfish/asadmin.pass',
          'portbase'            => '4800',
          'resourcetype'        => 'javax.sql.DataSource',
          'dsclassname'         => 'com.mysql.jdbc.jdbc2.optional.MysqlDataSource',
          'properties'          => {
                                     'serverName'        => '127.0.0.1',
                                     'portNumber'        => '3306',
                                     'databaseName'      => 'uitpas_api',
                                     'User'              => 'uitpas_api',
                                     'Password'          => 'mypassword',
                                     'URL'               => 'jdbc:mysql://127.0.0.1:3306/uitpas_api',
                                     'driverClass'       => 'com.mysql.jdbc.Driver',
                                     'characterEncoding' => 'UTF-8',
                                     'useUnicode'        => true,
                                     'useSSL'            => false
                                   }
        )}

        it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitpas').with(
          'ensure'         => 'present',
          'portbase'       => '4800',
          'user'           => 'glassfish',
          'passwordfile'   => '/home/glassfish/asadmin.pass',
          'connectionpool' => 'mysql_uitpas_api_j2eePool'
        ) }

        it { is_expected.to contain_profiles__glassfish__domain('uitpas').with(
          'portbase'       => '4800',
          'service_status' => 'running'
        ) }

        it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitpas') }

        it { is_expected.to contain_service('uitpas').with(
          'enable'    => true,
          'ensure'    => 'running',
          'hasstatus' => true
        ) }

        it { is_expected.to contain_class('profiles::uitpas::api::deployment').with(
          'database_password' => 'mypassword',
          'database_host'     => '127.0.0.1'
        ) }

        it { is_expected.to contain_package('liquibase').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('mysql-connector-j').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('liquibase').that_comes_before('Class[profiles::uitpas::api::deployment]') }
        it { is_expected.to contain_package('mysql-connector-j').that_comes_before('Class[profiles::uitpas::api::deployment]') }
        it { is_expected.to contain_profiles__mysql__app_user('uitpas_api').that_comes_before('Class[profiles::uitpas::api::deployment]') }
        it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').that_requires('Profiles::Glassfish::Domain[uitpas]') }
        it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').that_requires('Profiles::Mysql::App_user[uitpas_api]') }
        it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitpas').that_requires('Jdbcconnectionpool[mysql_uitpas_api_j2eePool]') }
        it { is_expected.to contain_profiles__glassfish__domain('uitpas').that_requires('Class[profiles::glassfish]') }
        it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitpas').that_requires('Profiles::Glassfish::Domain[uitpas]') }
        it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitpas').that_comes_before('Service[uitpas]') }
        it { is_expected.to contain_class('profiles::uitpas::api::deployment').that_requires('Class[profiles::glassfish]') }
      end

      context "with database_password => secret, database_host => db.example.com and portbase => 14800" do
        let(:params) { {
          'database_password' => 'secret',
          'database_host'     => 'db.example.com',
          'portbase'          => 14800
        } }

        it { is_expected.not_to contain_class('profiles::mysql::server') }

        it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').with(
          'ensure'              => 'present',
          'user'                => 'glassfish',
          'passwordfile'        => '/home/glassfish/asadmin.pass',
          'portbase'            => '14800',
          'resourcetype'        => 'javax.sql.DataSource',
          'dsclassname'         => 'com.mysql.jdbc.jdbc2.optional.MysqlDataSource',
          'properties'          => {
                                     'serverName'        => 'db.example.com',
                                     'portNumber'        => '3306',
                                     'databaseName'      => 'uitpas_api',
                                     'User'              => 'uitpas_api',
                                     'Password'          => 'secret',
                                     'URL'               => 'jdbc:mysql://db.example.com:3306/uitpas_api',
                                     'driverClass'       => 'com.mysql.jdbc.Driver',
                                     'characterEncoding' => 'UTF-8',
                                     'useUnicode'        => true,
                                     'useSSL'            => false
                                   }
        )}

        it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitpas').with(
          'ensure'         => 'present',
          'portbase'       => '14800',
          'user'           => 'glassfish',
          'passwordfile'   => '/home/glassfish/asadmin.pass',
          'connectionpool' => 'mysql_uitpas_api_j2eePool'
        ) }

        it { is_expected.to contain_profiles__glassfish__domain('uitpas').with(
          'portbase' => '14800'
        ) }

        it { is_expected.to contain_class('profiles::uitpas::api::deployment').with(
          'database_password' => 'secret',
          'database_host'     => 'db.example.com',
          'portbase'          => 14800
        ) }
      end

      context "with database_password => mysecret and deployment => false" do
        let(:params) { {
          'database_password' => 'mysecret',
          'deployment'        => false
        } }

        it { is_expected.not_to contain_class('profiles::uitpas::api::deployment') }
      end

      context "with database_password => foo and service_status => stopped" do
        let(:params) { {
          'database_password' => 'foo',
          'service_status'    => 'stopped'
        } }

        it { is_expected.to contain_profiles__glassfish__domain('uitpas').with(
          'portbase'       => '4800',
          'service_status' => 'stopped'
        ) }

        it { is_expected.to contain_service('uitpas').with(
          'enable'    => false,
          'ensure'    => 'stopped',
          'hasstatus' => true
        ) }

      end
    end
  end
end
