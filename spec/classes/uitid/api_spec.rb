describe 'profiles::uitid::api' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'in the production environment' do
        let(:environment) { 'production' }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with database_password => foo" do
            let(:params) { {
              'database_password' => 'foo'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_apt__source('publiq-tools') }

            it { is_expected.to contain_class('profiles::uitid::api').with(
              'database_password'    => 'foo',
              'database_host'        => '127.0.0.1',
              'deployment'           => true,
              'initial_heap_size'    => nil,
              'maximum_heap_size'    => '512m',
              'jmx'                  => true,
              'newrelic'             => false,
              'newrelic_license_key' => 'my_license_key',
              'portbase'             => 4800,
              'service_status'       => 'running',
              'settings'             => {}
            ) }

            it { is_expected.to contain_group('glassfish') }
            it { is_expected.to contain_user('glassfish') }

            it { is_expected.to contain_package('mysql-connector-j').with(
              'ensure' => 'present'
            ) }

            it { is_expected.to contain_class('profiles::java') }
            it { is_expected.to contain_class('profiles::glassfish') }
            it { is_expected.to contain_class('profiles::mysql::server') }

            it { is_expected.to contain_mysql_database('uitid_api').with(
              'charset' => 'utf8mb4',
              'collate' => 'utf8mb4_unicode_ci'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('uitid_api@uitid_api').with(
              'password' => 'foo',
              'remote'   => false
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('etl@uitid_api').with(
              'password' => 'my_etl_password',
              'remote'   => false,
              'readonly' => true
            ) }

            it { is_expected.to contain_jdbcconnectionpool('mysql_uitid_api_j2eePool').with(
              'ensure'              => 'present',
              'user'                => 'glassfish',
              'passwordfile'        => '/home/glassfish/asadmin.pass',
              'portbase'            => '4800',
              'resourcetype'        => 'javax.sql.DataSource',
              'dsclassname'         => 'com.mysql.cj.jdbc.MysqlDataSource',
              'properties'          => {
                                         'serverName'        => '127.0.0.1',
                                         'portNumber'        => '3306',
                                         'databaseName'      => 'uitid_api',
                                         'User'              => 'uitid_api',
                                         'Password'          => 'foo',
                                         'URL'               => 'jdbc:mysql://127.0.0.1:3306/uitid_api',
                                         'driverClass'       => 'com.mysql.cj.jdbc.Driver',
                                         'characterEncoding' => 'UTF-8',
                                         'useUnicode'        => true,
                                         'useSSL'            => false
                                       }
            ) }

            it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitid').with(
              'ensure'         => 'present',
              'portbase'       => '4800',
              'user'           => 'glassfish',
              'passwordfile'   => '/home/glassfish/asadmin.pass',
              'connectionpool' => 'mysql_uitid_api_j2eePool'
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

            it { is_expected.to contain_jvmoption('Clear domain uitid default truststore').with(
              'ensure'       => 'absent',
              'option'       => '-Djavax.net.ssl.trustStore=\$\{com.sun.aas.instanceRoot\}/config/cacerts.jks',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '4800'
            ) }

            it { is_expected.to contain_jvmoption('Domain uitid truststore').with(
              'ensure'       => 'present',
              'option'       => '-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '4800'
            ) }

            it { is_expected.to contain_jvmoption('Domain uitid timezone').with(
              'ensure'       => 'present',
              'option'       => '-Duser.timezone=CET',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '4800'
            ) }

            it { is_expected.to contain_profiles__glassfish__domain('uitid').with(
              'portbase'             => '4800',
              'initial_heap_size'    => nil,
              'maximum_heap_size'    => '512m',
              'jmx'                  => true,
              'newrelic'             => false,
              'newrelic_license_key' => 'my_license_key',
              'newrelic_app_name'    => 'uitid-api-production',
              'service_status'       => 'running'
            ) }

            it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitid') }

            it { is_expected.to contain_service('uitid').with(
              'enable'    => true,
              'ensure'    => 'running',
              'hasstatus' => true
            ) }

            it { is_expected.to contain_file('Domain uitid mysql-connector-j').with(
              'ensure' => 'file',
              'path'   => '/opt/payara/glassfish/lib/mysql-connector-j.jar',
              'source' => '/usr/share/java/mysql-connector-j.jar'
            ) }

            it { is_expected.to contain_class('profiles::uitid::api::deployment').with(
              'portbase' => 4800
            ) }

            it { is_expected.to contain_class('profiles::uitid::api::cron').with(
              'portbase' => 4800
            ) }

            it { is_expected.to contain_class('profiles::uitid::api::data_integration').with(
              'database_name' => 'uitid_api',
              'database_host' => '127.0.0.1'
            ) }

            it { is_expected.to contain_package('mysql-connector-j').that_requires('Apt::Source[publiq-tools]') }
            it { is_expected.to contain_package('mysql-connector-j').that_comes_before('Class[profiles::uitid::api::deployment]') }
            it { is_expected.to contain_class('profiles::mysql::server').that_comes_before('Mysql_database[uitid_api]') }
            it { is_expected.to contain_profiles__mysql__app_user('uitid_api@uitid_api').that_requires('Mysql_database[uitid_api]') }
            it { is_expected.to contain_profiles__mysql__app_user('etl@uitid_api').that_requires('Mysql_database[uitid_api]') }
            it { is_expected.to contain_profiles__mysql__app_user('uitid_api@uitid_api').that_comes_before('Class[profiles::uitid::api::deployment]') }
            it { is_expected.to contain_jdbcconnectionpool('mysql_uitid_api_j2eePool').that_requires('Profiles::Glassfish::Domain[uitid]') }
            it { is_expected.to contain_jdbcconnectionpool('mysql_uitid_api_j2eePool').that_requires('Profiles::Mysql::App_user[uitid_api@uitid_api]') }
            it { is_expected.to contain_jdbcconnectionpool('mysql_uitid_api_j2eePool').that_notifies('Service[uitid]') }
            it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitid').that_requires('Jdbcconnectionpool[mysql_uitid_api_j2eePool]') }
            it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitid').that_notifies('Service[uitid]') }
            it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').that_requires('Profiles::Glassfish::Domain[uitid]') }
            it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').that_notifies('Service[uitid]') }
            it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').that_requires('Profiles::Glassfish::Domain[uitid]') }
            it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').that_notifies('Service[uitid]') }
            it { is_expected.to contain_jvmoption('Clear domain uitid default truststore').that_requires('Profiles::Glassfish::Domain[uitid]') }
            it { is_expected.to contain_jvmoption('Clear domain uitid default truststore').that_notifies('Service[uitid]') }
            it { is_expected.to contain_jvmoption('Domain uitid truststore').that_requires('Profiles::Glassfish::Domain[uitid]') }
            it { is_expected.to contain_jvmoption('Domain uitid truststore').that_notifies('Service[uitid]') }
            it { is_expected.to contain_jvmoption('Domain uitid timezone').that_requires('Profiles::Glassfish::Domain[uitid]') }
            it { is_expected.to contain_jvmoption('Domain uitid timezone').that_notifies('Service[uitid]') }
            it { is_expected.to contain_profiles__glassfish__domain('uitid').that_requires('Class[profiles::glassfish]') }
            it { is_expected.to contain_profiles__glassfish__domain('uitid').that_notifies('Service[uitid]') }
            it { is_expected.to contain_profiles__glassfish__domain('uitid').that_comes_before('Class[profiles::uitid::api::deployment]') }
            it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitid').that_requires('Profiles::Glassfish::Domain[uitid]') }
            it { is_expected.to contain_profiles__glassfish__domain__service_alias('uitid').that_comes_before('Service[uitid]') }
            it { is_expected.to contain_file('Domain uitid mysql-connector-j').that_requires('Package[mysql-connector-j]') }
            it { is_expected.to contain_file('Domain uitid mysql-connector-j').that_comes_before('Profiles::Glassfish::Domain[uitid]') }
            it { is_expected.to contain_file('Domain uitid mysql-connector-j').that_comes_before('Class[profiles::uitid::api::deployment]') }
            it { is_expected.to contain_class('profiles::uitid::api::deployment').that_requires('Class[profiles::glassfish]') }
            it { is_expected.to contain_class('profiles::uitid::api::deployment').that_notifies('Service[uitid]') }
            it { is_expected.to contain_class('profiles::uitid::api::data_integration').that_requires('Class[profiles::uitid::api::deployment]') }
            it { is_expected.to contain_class('profiles::uitid::api::cron').that_requires('Class[profiles::uitid::api::deployment]') }
          end

          context "with database_password => secret, database_host => db.example.com, initial_heap_size => 1024m, maximum_heap_size => 1536m, jmx => false, newrelic => true, portbase => 14800 and settings => { 'foo' => 'bar', 'baz' => 'test' }" do
            let(:params) { {
              'database_password' => 'secret',
              'database_host'     => 'db.example.com',
              'initial_heap_size' => '1024m',
              'maximum_heap_size' => '1536m',
              'jmx'               => false,
              'newrelic'          => true,
              'portbase'          => 14800,
              'settings'          => { 'foo' => 'bar', 'baz' => 'test' }
            } }

            it { is_expected.not_to contain_class('profiles::mysql::server') }

            it { is_expected.to contain_class('profiles::mysql::remote_server').with(
              'host' => 'db.example.com'
            ) }

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

            it { is_expected.to contain_profiles__glassfish__domain('uitid').with(
              'initial_heap_size'    => '1024m',
              'maximum_heap_size'    => '1536m',
              'jmx'                  => false,
              'newrelic'             => true,
              'newrelic_license_key' => 'my_license_key',
              'portbase'             => '14800'
            ) }

            it { is_expected.to contain_systemproperty('foo').that_requires('Profiles::Glassfish::Domain[uitid]') }
            it { is_expected.to contain_systemproperty('foo').that_notifies('Service[uitid]') }
            it { is_expected.to contain_systemproperty('baz').that_requires('Profiles::Glassfish::Domain[uitid]') }
            it { is_expected.to contain_systemproperty('baz').that_notifies('Service[uitid]') }

            context "with fact mysqld_version => 8.0.33" do
              let(:facts) { facts.merge( { 'mysqld_version' => '8.0.33' } ) }

              it { is_expected.to contain_mysql_database('uitid_api').with(
                'charset' => 'utf8mb4',
                'collate' => 'utf8mb4_unicode_ci'
              ) }

              it { is_expected.to contain_profiles__mysql__app_user('uitid_api@uitid_api').with(
                'password' => 'secret',
                'remote'   => true
              ) }

              it { is_expected.to contain_profiles__mysql__app_user('etl@uitid_api').with(
                'password' => 'my_etl_password',
                'remote'   => true,
                'readonly' => true
              ) }

              it { is_expected.to contain_jdbcconnectionpool('mysql_uitid_api_j2eePool').with(
                'ensure'              => 'present',
                'user'                => 'glassfish',
                'passwordfile'        => '/home/glassfish/asadmin.pass',
                'portbase'            => '14800',
                'resourcetype'        => 'javax.sql.DataSource',
                'dsclassname'         => 'com.mysql.cj.jdbc.MysqlDataSource',
                'properties'          => {
                                           'serverName'        => 'db.example.com',
                                           'portNumber'        => '3306',
                                           'databaseName'      => 'uitid_api',
                                           'User'              => 'uitid_api',
                                           'Password'          => 'secret',
                                           'URL'               => 'jdbc:mysql://db.example.com:3306/uitid_api',
                                           'driverClass'       => 'com.mysql.cj.jdbc.Driver',
                                           'characterEncoding' => 'UTF-8',
                                           'useUnicode'        => true,
                                           'useSSL'            => false
                                         }
              )}

              it { is_expected.to contain_jdbcresource('jdbc/cultuurnet_uitid').with(
                'ensure'         => 'present',
                'portbase'       => '14800',
                'user'           => 'glassfish',
                'passwordfile'   => '/home/glassfish/asadmin.pass',
                'connectionpool' => 'mysql_uitid_api_j2eePool'
              ) }

              it { is_expected.to contain_class('profiles::uitid::api::deployment').with(
                'portbase'          => 14800
              ) }

              it { is_expected.to contain_class('profiles::uitid::api::data_integration').with(
                'database_name' => 'uitid_api',
                'database_host' => 'db.example.com'
              ) }

              it { is_expected.to contain_class('profiles::uitid::api::cron').with(
                'portbase' => 14800
              ) }
            end

            context "without extra facts" do
              let(:facts) { facts }

              it { is_expected.not_to contain_mysql_database('uitid_api') }
              it { is_expected.not_to contain_profiles__mysql__app_user('uitid_api@uitid_api') }
              it { is_expected.not_to contain_profiles__mysql__app_user('etl@uitid_api') }
              it { is_expected.not_to contain_jdbcconnectionpool('mysql_uitid_api_j2eePool') }
              it { is_expected.not_to contain_jdbcresource('jdbc/cultuurnet_uitid') }
              it { is_expected.not_to contain_class('profiles::uitid::api::deployment') }
            end
          end
        end

        context "with database_password => mysecret and deployment => false" do
          let(:params) { {
            'database_password' => 'mysecret',
            'deployment'        => false
          } }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.not_to contain_class('profiles::uitid::api::deployment') }
            it { is_expected.not_to contain_class('profiles::uitid::api::data_integration') }
            it { is_expected.not_to contain_class('profiles::uitid::api::cron') }
          end
        end
      end

      context 'without hieradata' do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_password'/) }
      end

      context 'in the testing environment' do
        let(:environment) { 'testing' }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context "with database_password => foo, newrelic => true, newrelic_license_key => bar and service_status => stopped" do
            let(:params) { {
              'database_password'    => 'foo',
              'newrelic'             => true,
              'newrelic_license_key' => 'bar',
              'service_status'       => 'stopped'
            } }

            it { is_expected.to contain_profiles__glassfish__domain('uitid').with(
              'initial_heap_size'    => nil,
              'maximum_heap_size'    => '512m',
              'jmx'                  => true,
              'newrelic'             => true,
              'newrelic_app_name'    => 'uitid-api-testing',
              'newrelic_license_key' => 'bar',
              'portbase'             => '4800',
              'service_status'       => 'stopped'
            ) }

            it { is_expected.to contain_service('uitid').with(
              'enable'    => false,
              'ensure'    => 'stopped',
              'hasstatus' => true
            ) }
          end
        end
      end
    end
  end
end
