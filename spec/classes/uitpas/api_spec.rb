describe 'profiles::uitpas::api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with database_password => mypassword" do
        let(:params) { {
          'database_password' => 'mypassword'
        } }

        context 'in the production environment' do
          let(:environment) { 'production' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitpas::api').with(
            'database_password' => 'mypassword',
            'database_host'     => '127.0.0.1',
            'deployment'        => true,
            'initial_heap'      => nil,
            'maximum_heap'      => nil,
            'jmx'               => true,
            'newrelic'          => true,
            'portbase'          => 4800,
            'service_status'    => 'running',
            'settings'          => {}
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

          it { is_expected.to contain_profiles__mysql__app_user('uitpas_api@uitpas_api').with(
            'password' => 'mypassword',
            'remote'   => false
          ) }

          it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').with(
            'ensure'              => 'present',
            'user'                => 'glassfish',
            'passwordfile'        => '/home/glassfish/asadmin.pass',
            'portbase'            => '4800',
            'resourcetype'        => 'javax.sql.DataSource',
            'dsclassname'         => 'com.mysql.cj.jdbc.MysqlDataSource',
            'properties'          => {
                                       'serverName'        => '127.0.0.1',
                                       'portNumber'        => '3306',
                                       'databaseName'      => 'uitpas_api',
                                       'User'              => 'uitpas_api',
                                       'Password'          => 'mypassword',
                                       'URL'               => 'jdbc:mysql://127.0.0.1:3306/uitpas_api',
                                       'driverClass'       => 'com.mysql.cj.jdbc.Driver',
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

          it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').with(
            'ensure'       => 'present',
            'value'        => 'X-Forwarded-Proto',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').with(
            'ensure'       => 'present',
            'value'        => '32',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Clear domain uitpas default truststore').with(
            'ensure'       => 'absent',
            'option'       => '-Djavax.net.ssl.trustStore=\$\{com.sun.aas.instanceRoot\}/config/cacerts.jks',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain uitpas truststore').with(
            'ensure'       => 'present',
            'option'       => '-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain uitpas timezone').with(
            'ensure'       => 'present',
            'option'       => '-Duser.timezone=CET',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_profiles__glassfish__domain('uitpas').with(
            'portbase'          => '4800',
            'initial_heap'      => nil,
            'maximum_heap'      => nil,
            'jmx'               => true,
            'newrelic'          => true,
            'newrelic_app_name' => 'uitpas-api-production',
            'service_status'    => 'running'
          ) }

          it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitpas') }

          it { is_expected.to contain_service('uitpas').with(
            'enable'    => true,
            'ensure'    => 'running',
            'hasstatus' => true
          ) }

          it { is_expected.to contain_file('Domain uitpas mysql-connector-j').with(
            'ensure' => 'file',
            'path'   => '/opt/payara/glassfish/lib/mysql-connector-j.jar',
            'source' => '/usr/share/java/mysql-connector-j.jar'
          ) }

          it { is_expected.to contain_class('profiles::uitpas::api::deployment').with(
            'database_password' => 'mypassword',
            'database_host'     => '127.0.0.1'
          ) }

          it { is_expected.to contain_package('liquibase').that_requires('Apt::Source[publiq-tools]') }
          it { is_expected.to contain_package('mysql-connector-j').that_requires('Apt::Source[publiq-tools]') }
          it { is_expected.to contain_package('liquibase').that_comes_before('Class[profiles::uitpas::api::deployment]') }
          it { is_expected.to contain_package('mysql-connector-j').that_comes_before('Class[profiles::uitpas::api::deployment]') }
          it { is_expected.to contain_profiles__mysql__app_user('uitpas_api@uitpas_api').that_comes_before('Class[profiles::uitpas::api::deployment]') }
          it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').that_requires('Profiles::Glassfish::Domain[uitpas]') }
          it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').that_requires('Profiles::Mysql::App_user[uitpas_api@uitpas_api]') }
          it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitpas').that_requires('Jdbcconnectionpool[mysql_uitpas_api_j2eePool]') }
          it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').that_requires('Profiles::Glassfish::Domain[uitpas]') }
          it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').that_notifies('Service[uitpas]') }
          it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').that_requires('Profiles::Glassfish::Domain[uitpas]') }
          it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').that_notifies('Service[uitpas]') }
          it { is_expected.to contain_jvmoption('Clear domain uitpas default truststore').that_requires('Profiles::Glassfish::Domain[uitpas]') }
          it { is_expected.to contain_jvmoption('Clear domain uitpas default truststore').that_notifies('Service[uitpas]') }
          it { is_expected.to contain_jvmoption('Domain uitpas truststore').that_requires('Profiles::Glassfish::Domain[uitpas]') }
          it { is_expected.to contain_jvmoption('Domain uitpas truststore').that_notifies('Service[uitpas]') }
          it { is_expected.to contain_jvmoption('Domain uitpas timezone').that_requires('Profiles::Glassfish::Domain[uitpas]') }
          it { is_expected.to contain_jvmoption('Domain uitpas timezone').that_notifies('Service[uitpas]') }
          it { is_expected.to contain_profiles__glassfish__domain('uitpas').that_requires('Class[profiles::glassfish]') }
          it { is_expected.to contain_profiles__glassfish__domain('uitpas').that_notifies('Service[uitpas]') }
          it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitpas').that_requires('Profiles::Glassfish::Domain[uitpas]') }
          it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitpas').that_comes_before('Service[uitpas]') }
          it { is_expected.to contain_file('Domain uitpas mysql-connector-j').that_requires('Package[mysql-connector-j]') }
          it { is_expected.to contain_file('Domain uitpas mysql-connector-j').that_comes_before('Profiles::Glassfish::Domain[uitpas]') }
          it { is_expected.to contain_file('Domain uitpas mysql-connector-j').that_comes_before('Class[profiles::uitpas::api::deployment]') }
          it { is_expected.to contain_class('profiles::uitpas::api::deployment').that_requires('Class[profiles::glassfish]') }
        end
      end

      context "with database_password => secret, database_host => db.example.com, initial_heap => 1024m, maximum_heap => 1536m, jmx => false, newrelic => false, portbase => 14800 and settings => { 'foo' => 'bar', 'baz' => 'test' }" do
        let(:params) { {
          'database_password' => 'secret',
          'database_host'     => 'db.example.com',
          'initial_heap'      => '1024m',
          'maximum_heap'      => '1536m',
          'jmx'               => false,
          'newrelic'          => false,
          'portbase'          => 14800,
          'settings'          => { 'foo' => 'bar', 'baz' => 'test' }
        } }

        it { is_expected.not_to contain_class('profiles::mysql::server') }
        it { is_expected.to contain_class('profiles::mysql::rds') }

        it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').with(
          'ensure'       => 'present',
          'value'        => 'X-Forwarded-Proto',
          'user'         => 'glassfish',
          'passwordfile' => '/home/glassfish/asadmin.pass',
          'portbase'     => '14800'
        ) }

        it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').with(
          'ensure'       => 'present',
          'value'        => '32',
          'user'         => 'glassfish',
          'passwordfile' => '/home/glassfish/asadmin.pass',
          'portbase'     => '14800'
        ) }

        it { is_expected.to contain_systemproperty('foo').with(
          'ensure'         => 'present',
          'value'          => 'bar',
          'portbase'       => '14800',
          'user'           => 'glassfish',
          'passwordfile'   => '/home/glassfish/asadmin.pass',
        ) }

        it { is_expected.to contain_systemproperty('baz').with(
          'ensure'         => 'present',
          'value'          => 'test',
          'portbase'       => '14800',
          'user'           => 'glassfish',
          'passwordfile'   => '/home/glassfish/asadmin.pass',
        ) }

        it { is_expected.to contain_profiles__glassfish__domain('uitpas').with(
          'initial_heap' => '1024m',
          'maximum_heap' => '1536m',
          'jmx'          => false,
          'newrelic'     => false,
          'portbase'     => '14800'
        ) }

        it { is_expected.to contain_systemproperty('foo').that_requires('Profiles::Glassfish::Domain[uitpas]') }
        it { is_expected.to contain_systemproperty('foo').that_notifies('Service[uitpas]') }
        it { is_expected.to contain_systemproperty('baz').that_requires('Profiles::Glassfish::Domain[uitpas]') }
        it { is_expected.to contain_systemproperty('baz').that_notifies('Service[uitpas]') }

        context "with fact mysqld_version => 8.0.33" do
          let(:facts) { facts.merge( { 'mysqld_version' => '8.0.33' } ) }

          it { is_expected.to contain_mysql_database('uitpas_api').with(
            'charset' => 'utf8mb4',
            'collate' => 'utf8mb4_unicode_ci'
          ) }

          it { is_expected.to contain_profiles__mysql__app_user('uitpas_api@uitpas_api').with(
            'password' => 'secret',
            'remote'   => true
          ) }

          it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool').with(
            'ensure'              => 'present',
            'user'                => 'glassfish',
            'passwordfile'        => '/home/glassfish/asadmin.pass',
            'portbase'            => '14800',
            'resourcetype'        => 'javax.sql.DataSource',
            'dsclassname'         => 'com.mysql.cj.jdbc.MysqlDataSource',
            'properties'          => {
                                       'serverName'        => 'db.example.com',
                                       'portNumber'        => '3306',
                                       'databaseName'      => 'uitpas_api',
                                       'User'              => 'uitpas_api',
                                       'Password'          => 'secret',
                                       'URL'               => 'jdbc:mysql://db.example.com:3306/uitpas_api',
                                       'driverClass'       => 'com.mysql.cj.jdbc.Driver',
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

          it { is_expected.to contain_class('profiles::uitpas::api::deployment').with(
            'database_password' => 'secret',
            'database_host'     => 'db.example.com',
            'portbase'          => 14800
          ) }
        end

        context "without extra facts" do
          let(:facts) { facts }

          it { is_expected.not_to contain_mysql_database('uitpas_api') }
          it { is_expected.not_to contain_profiles__mysql__app_user('uitpas_api@uitpas_api') }
          it { is_expected.not_to contain_jdbcconnectionpool('mysql_uitpas_api_j2eePool') }
          it { is_expected.not_to contain_jdbcresource('jdbc/cultuurnet_uitpas') }
          it { is_expected.not_to contain_class('profiles::uitpas::api::deployment') }
        end
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

        context 'in the testing environment' do
          let(:environment) { 'testing' }

          it { is_expected.to contain_profiles__glassfish__domain('uitpas').with(
            'initial_heap'      => nil,
            'maximum_heap'      => nil,
            'jmx'               => true,
            'newrelic'          => true,
            'newrelic_app_name' => 'uitpas-api-testing',
            'portbase'          => '4800',
            'service_status'    => 'stopped'
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
end
